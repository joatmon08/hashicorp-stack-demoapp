resource "vault_mount" "postgres" {
  path = "database"
  type = "database"
}

resource "vault_database_secret_backend_connection" "postgres" {
  count         = var.postgres_hostname != "" ? 1 : 0
  backend       = vault_mount.postgres.path
  name          = "products"
  allowed_roles = ["*"]

  postgresql {
    connection_url = "postgresql://${var.postgres_username}:${var.postgres_password}@${var.postgres_hostname}:${var.postgres_port}/products?sslmode=disable"
  }
}

resource "vault_database_secret_backend_role" "postgres" {
  count                 = var.postgres_hostname != "" ? 1 : 0
  backend               = vault_mount.postgres.path
  name                  = "products"
  db_name               = vault_database_secret_backend_connection.postgres.0.name
  creation_statements   = ["CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";"]
  revocation_statements = ["ALTER ROLE \"{{name}}\" NOLOGIN;"]
  default_ttl           = 3600
  max_ttl               = 3600
}

data "vault_policy_document" "products" {
  count = var.postgres_hostname != "" ? 1 : 0
  rule {
    path         = "database/creds/products"
    capabilities = ["read"]
    description  = "read all products"
  }
}

resource "vault_policy" "products" {
  count  = var.postgres_hostname != "" ? 1 : 0
  name   = "products"
  policy = data.vault_policy_document.products.0.hcl
}