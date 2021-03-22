resource "vault_mount" "postgres" {
  depends_on = [helm_release.vault]
  path       = "database"
  type       = "database"
}

resource "vault_database_secret_backend_connection" "postgres" {
  depends_on    = [helm_release.vault]
  backend       = vault_mount.postgres.path
  name          = "product"
  allowed_roles = ["*"]

  postgresql {
    connection_url = "postgresql://${local.postgres_username}:${local.postgres_password}@${local.postgres_hostname}:${var.postgres_port}/products?sslmode=disable"
  }
}

resource "vault_database_secret_backend_role" "postgres" {
  depends_on            = [helm_release.vault]
  backend               = vault_mount.postgres.path
  name                  = "product"
  db_name               = vault_database_secret_backend_connection.postgres.name
  creation_statements   = ["CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";"]
  revocation_statements = ["ALTER ROLE \"{{name}}\" NOLOGIN;"]
  default_ttl           = 3600
  max_ttl               = 3600
}

data "vault_policy_document" "product" {
  depends_on = [helm_release.vault]
  rule {
    path         = "database/creds/product"
    capabilities = ["read"]
    description  = "read all product"
  }
}

resource "vault_policy" "product" {
  depends_on = [helm_release.vault]
  name       = "product"
  policy     = data.vault_policy_document.product.hcl
}