resource "vault_mount" "static" {
  path        = "${var.business_unit}/static"
  type        = "kv-v2"
  description = "For static secrets related to ${var.business_unit}"
}

locals {
  database_secret_name = var.db_name
}

resource "vault_generic_secret" "postgres" {
  path = "${vault_mount.static.path}/${local.database_secret_name}"

  data_json = <<EOT
{
  "username": "${aws_db_instance.database.username}",
  "password": "${aws_db_instance.database.password}"
}
EOT
}

data "vault_policy_document" "postgres" {
  rule {
    path         = "${vault_mount.static.path}/data/${local.database_secret_name}"
    capabilities = ["read"]
    description  = "Allow access to database admin username and password for database ${var.db_name} belonging to ${var.business_unit}"
  }
}

resource "vault_policy" "postgres" {
  name   = "products-db-admin"
  policy = data.vault_policy_document.postgres.hcl
}

data "vault_generic_secret" "database" {
  path = "${vault_mount.static.path}/${local.database_secret_name}"
}