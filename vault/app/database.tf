resource "vault_mount" "postgres" {
  path = "database"
  type = "database"
}

resource "vault_database_secret_backend_connection" "postgres" {
  backend       = vault_mount.postgres.path
  name          = "product"
  allowed_roles = ["*"]

  postgresql {
    connection_url = "postgresql://{{username}}:{{password}}@${local.postgres_hostname}:${var.postgres_port}/products?sslmode=disable"
    username       = local.postgres_username
    password       = local.postgres_password
  }
}

resource "vault_database_secret_backend_role" "postgres" {
  backend               = vault_mount.postgres.path
  name                  = "product"
  db_name               = vault_database_secret_backend_connection.postgres.name
  creation_statements   = ["CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";"]
  revocation_statements = ["ALTER ROLE \"{{name}}\" NOLOGIN;"]
  default_ttl           = 3600
  max_ttl               = 3600
}

data "vault_policy_document" "product" {
  rule {
    path         = "database/creds/product"
    capabilities = ["read"]
    description  = "read all product"
  }
}

resource "vault_policy" "product" {
  name   = "product"
  policy = data.vault_policy_document.product.hcl
}

resource "vault_kubernetes_auth_backend_role" "product" {
  backend                          = local.vault_kubernetes_auth_path
  role_name                        = "product"
  bound_service_account_names      = ["product"]
  bound_service_account_namespaces = ["default"]
  token_ttl                        = 3600
  token_policies                   = [vault_policy.product.name]
}