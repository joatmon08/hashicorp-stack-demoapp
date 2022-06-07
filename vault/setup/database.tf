resource "vault_mount" "static" {
  path        = "static/admin/products"
  type        = "kv-v2"
  description = "For static secrets"
}

locals {
  database_secret_name = "postgres"
}

resource "vault_generic_secret" "postgres" {
  path = "${vault_mount.static.path}/${local.database_secret_name}"

  data_json = <<EOT
{
  "username": "${local.postgres_username}",
  "password": "${local.postgres_password}"
}
EOT
}

data "vault_policy_document" "postgres" {
  rule {
    path         = "${vault_mount.static.path}/data/${local.database_secret_name}"
    capabilities = ["read"]
    description  = "Allow access to PostgreSQL database admin credentials"
  }
}

resource "vault_policy" "postgres" {
  name   = "products-db-admin"
  policy = data.vault_policy_document.postgres.hcl
}