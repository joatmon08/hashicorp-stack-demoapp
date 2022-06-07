locals {
  database_path                     = "database"
  application_name                  = "product"
  consul_terraform_sync_secret_name = "consul-terraform-sync"
}

data "vault_policy_document" "cts" {
  rule {
    path         = "${local.vault_database_static_path}/data/${local.vault_database_secret_name}"
    capabilities = ["read"]
    description  = "Allow CTS to access PostgreSQL database admin credentials"
  }

  rule {
    path         = "${local.vault_database_static_path}/data/${local.consul_terraform_sync_secret_name}"
    capabilities = ["read"]
    description  = "Allow CTS to access Consul token and Vault address"
  }

  rule {
    path         = "auth/token/create"
    capabilities = ["update"]
    description  = "Allow CTS to create child token for additional configuration"
  }

  rule {
    path         = "/sys/mounts"
    capabilities = ["read"]
    description  = "Allow CTS to get a list of secrets engines"
  }

  rule {
    path         = "/sys/mounts/${local.database_path}/*"
    capabilities = ["create", "read", "update", "delete", "list"]
    description  = "Allow CTS to manage mounts for databases"
  }

  rule {
    path         = "/${local.database_path}/${local.application_name}/*"
    capabilities = ["create", "read", "update", "delete", "list"]
    description  = "Allow CTS to set up database secrets engine at application database path"
  }

  rule {
    path         = "/sys/policies/acl/${local.application_name}"
    capabilities = ["create", "read", "update", "delete", "list"]
    description  = "Allow CTS to set up ACL policy for application"
  }

  rule {
    path         = "/auth/kubernetes/role/${local.application_name}"
    capabilities = ["create", "read", "update", "delete", "list"]
    description  = "Allow CTS to set up Kubernetes auth method for application"
  }
}

resource "vault_policy" "cts" {
  name   = "consul-terraform-sync"
  policy = data.vault_policy_document.cts.hcl
}