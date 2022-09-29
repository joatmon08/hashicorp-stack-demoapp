locals {
  cts_port = 8558
}

resource "kubernetes_service" "cts" {
  metadata {
    name      = "consul-terraform-sync"
    namespace = var.kubernetes_namespace
    labels = {
      "app" = "consul-terraform-sync"
    }
  }
  spec {
    selector = {
      app = "consul-terraform-sync"
    }

    port {
      port        = local.cts_port
      target_port = local.cts_port
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_service_account" "cts" {
  metadata {
    name      = "consul-terraform-sync"
    namespace = var.kubernetes_namespace
  }
  automount_service_account_token = true
}

resource "kubernetes_role" "secrets_writer" {
  metadata {
    name      = "secrets-writer"
    namespace = var.kubernetes_namespace
  }

  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }

  rule {
    api_groups = ["coordination.k8s.io"]
    resources  = ["leases"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }
}

resource "kubernetes_role_binding" "cts" {
  metadata {
    name      = "consul-terraform-sync"
    namespace = var.kubernetes_namespace
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.secrets_writer.metadata.0.name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.cts.metadata.0.name
    namespace = kubernetes_service_account.cts.metadata.0.namespace
  }
}

resource "kubernetes_manifest" "cts_service_defaults" {
  manifest = {
    "apiVersion" = "consul.hashicorp.com/v1alpha1"
    "kind"       = "ServiceDefaults"
    "metadata" = {
      "name"      = "consul-terraform-sync"
      "namespace" = var.kubernetes_namespace
    }
    "spec" = {
      "protocol" = "http"
    }
  }
}

resource "kubernetes_config_map" "cts" {
  metadata {
    name      = "consul-terraform-sync"
    namespace = var.kubernetes_namespace
  }

  data = {
    "config.hcl" = <<EOT
log_level   = "INFO"
working_dir = "sync-tasks"
port        = ${local.cts_port}

syslog {}

buffer_period {
  enabled = true
  min     = "5s"
  max     = "20s"
}

consul {
  address = "${local.consul_address}"

  tls {
    enabled = true
    verify  = false
  }

  service_registration {
    enabled = true
    service_name = "Consul-Terraform-Sync"
    default_check {
      enabled = false
    }
  }
}

driver "terraform" {
  log         = true
  persist_log = false

  backend "kubernetes" {
    secret_suffix     = "state"
    in_cluster_config = true
  }
}

terraform_provider "vault" {}

task {
  name        = "products-database"
  description = "Task to create database secrets engine for product PostgreSQL database"
  module      = "joatmon08/postgres-nia/vault"
  version     = "0.0.1"
  providers   = ["vault"]

  variable_files = ["/vault/secrets/terraform.tfvars"]

  condition "services" {
    names      = ["database"]
    datacenter = "${local.consul_datacenter}"
  }
}
EOT
  }
}

resource "kubernetes_deployment" "cts" {
  metadata {
    name = "consul-terraform-sync"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        service = "consul-terraform-sync"
        app     = "consul-terraform-sync"
      }
    }

    template {
      metadata {
        labels = {
          app     = "consul-terraform-sync"
          service = "consul-terraform-sync"
        }
        annotations = {
          "vault.hashicorp.com/agent-inject"                           = "true"
          "vault.hashicorp.com/agent-inject-secret-auth"               = "static/admin/products/data/consul-terraform-sync"
          "vault.hashicorp.com/agent-inject-secret-terraform.tfvars"   = "static/admin/products/data/postgres"
          "vault.hashicorp.com/agent-inject-template-auth"             = <<-EOT
          {{ with secret "static/admin/products/data/consul-terraform-sync" -}}
          export VAULT_ADDR="{{ .Data.data.vault_addr }}"
          export CONSUL_HTTP_TOKEN="{{ .Data.data.token }}"
          {{- end }}
          EOT
          "vault.hashicorp.com/agent-inject-template-terraform.tfvars" = <<-EOT
          name                             = "product"
          {{ with secret "static/admin/products/data/postgres" -}}
          postgres_username                = "{{ .Data.data.username }}"
          postgres_password                = "{{ .Data.data.password }}"
          {{- end }}
          postgres_database_name           = "products"
          vault_kubernetes_auth_path       = "kubernetes"
          bound_service_account_names      = ["product"]
          bound_service_account_namespaces = ["default"]
          allowed_roles                    = ["product"]
          EOT
          "vault.hashicorp.com/agent-inject-token"                     = "true"
          "vault.hashicorp.com/namespace"                              = "admin"
          "vault.hashicorp.com/role"                                   = "consul-terraform-sync"
        }
      }

      spec {
        service_account_name = "consul-terraform-sync"
        container {
          image = "hashicorp/consul-terraform-sync:0.6.0"
          name  = "consul-terraform-sync"

          port {
            container_port = local.cts_port
          }

          command = ["/bin/sh"]
          args    = ["-c", "source /vault/secrets/auth && export VAULT_TOKEN=$(cat /vault/secrets/token) && /bin/docker-entrypoint.sh /bin/consul-terraform-sync"]

          volume_mount {
            name       = "config"
            mount_path = "/consul-terraform-sync/config"
            read_only  = true
          }
        }

        volume {
          name = "config"
          config_map {
            name = kubernetes_config_map.cts.metadata.0.name
          }
        }
      }
    }
  }
}
