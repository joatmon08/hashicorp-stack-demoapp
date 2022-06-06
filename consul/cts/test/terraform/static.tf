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