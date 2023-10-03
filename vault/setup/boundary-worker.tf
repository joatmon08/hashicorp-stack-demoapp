resource "vault_mount" "boundary_worker" {
  path        = "boundary/worker"
  type        = "kv"
  options     = { version = "2" }
  description = "Boundary worker tokens"
}

data "vault_policy_document" "boundary_worker" {
  rule {
    path         = "${vault_mount.boundary_worker.path}/*"
    capabilities = ["create", "update"]
    description  = "Allow Boundary workers to register their worker auth tokens into Vault"
  }
}

resource "vault_policy" "boundary_worker" {
  name   = "boundary-worker"
  policy = data.vault_policy_document.boundary_worker.hcl
}

resource "vault_token_auth_backend_role" "boundary_worker" {
  role_name              = "boundary-worker"
  allowed_policies       = [vault_policy.boundary_worker.name]
  disallowed_policies    = ["default"]
  orphan                 = true
  token_period           = "86400"
  renewable              = true
  token_explicit_max_ttl = "115200"
}

resource "vault_token" "boundary_worker" {
  role_name = vault_token_auth_backend_role.boundary_worker.role_name
  policies  = [vault_policy.boundary_worker.name]
}