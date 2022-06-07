resource "consul_acl_policy" "cts" {
  name        = "consul-terraform-sync"
  description = "Policy for Consul-Terraform-Sync self-registering and accessing database services"
  rules       = <<-RULE
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

resource "vault_generic_secret" "consul_terraform_sync" {
  path = "${local.vault_database_static_path}/consul-terraform-sync"

  data_json = <<EOT
{
  "token": "${data.consul_acl_token_secret_id.cts.secret_id}",
  "vault_addr": "${local.vault_addr}"
}
EOT
}