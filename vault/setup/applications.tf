data "vault_policy_document" "application" {
  rule {
    path         = "*/static"
    capabilities = ["create", "update"]
    description  = "Allow applications to enable KVv2"
  }
  rule {
    path         = "database/*"
    capabilities = ["create", "update"]
    description  = "Allow applications to enable database secrets engines"
  }
}

resource "vault_policy" "application" {
  name   = "application"
  policy = data.vault_policy_document.application.hcl
}

resource "vault_token_auth_backend_role" "application" {
  role_name              = "application"
  allowed_policies       = [vault_policy.application.name]
  disallowed_policies    = ["default"]
  orphan                 = true
  token_period           = "86400"
  renewable              = true
  token_explicit_max_ttl = "115200"
}

resource "vault_token" "application" {
  role_name = vault_token_auth_backend_role.application.role_name
  policies  = [vault_policy.application.name]
}