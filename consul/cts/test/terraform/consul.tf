resource "consul_acl_policy" "cts" {
  name  = "consul-terraform-sync"
  rules = <<-RULE
    service "Consul-Terraform-Sync" {
      policy = "write"
    }

    service "database" {
      policy = "read"
    }

    node_prefix "" {
      policy = "read"
    }
    RULE
}

resource "consul_acl_token" "cts" {
  description = "ACL token for Consul-Terraform-Sync"
  policies    = ["${consul_acl_policy.cts.name}"]
  local       = false
}

data "consul_acl_token_secret_id" "cts" {
  accessor_id = consul_acl_token.cts.id
}

## Set up CTS required secrets in Kubernetes ConfigMap
resource "kubernetes_secret" "cts" {
  metadata {
    name = "consul-terraform-sync"
  }

  data = {
    vault_addr   = "http://vault:8200"
    consul_token = data.consul_acl_token_secret_id.cts.secret_id
  }

  type = "Opaque"
}