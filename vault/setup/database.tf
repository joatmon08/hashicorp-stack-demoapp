resource "vault_mount" "static" {
  path        = "static/admin/products"
  type        = "kv-v2"
  description = "For static secrets"
}


resource "vault_generic_secret" "postgres" {
  path = "${vault_mount.static.path}/postgres"

  data_json = <<EOT
{
  "username": "${local.postgres_username}",
  "password": "${local.postgres_password}"
}
EOT
}

data "vault_policy_document" "postgres" {
  rule {
    path         = "${vault_mount.static.path}/data/postgres"
    capabilities = ["read"]
    description  = "Allow access to PostgreSQL database admin credentials"
  }
}

resource "vault_policy" "postgres" {
  name   = "products-db-admin"
  policy = data.vault_policy_document.postgres.hcl
}

resource "vault_kubernetes_auth_backend_role" "consul_terraform_sync" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "consul-terraform-sync"
  bound_service_account_names      = ["consul-terraform-sync"]
  bound_service_account_namespaces = ["default"]
  token_ttl                        = 3600
  token_policies                   = [vault_policy.postgres.name]
}