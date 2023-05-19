resource "vault_mount" "boundary_worker" {
  path        = "boundary/worker"
  type        = "kv"
  options     = { version = "2" }
  description = "Boundary worker tokens"
}

data "vault_policy_document" "boundary_worker" {
  rule {
    path         = "${vault_mount.boundary_worker.path}/*"
    capabilities = ["update"]
    description  = "Allow Boundary workers to register their worker auth tokens into Vault"
  }
}

resource "vault_policy" "boundary_worker" {
  name   = "boundary-worker"
  policy = data.vault_policy_document.boundary_worker.hcl
}

resource "vault_token" "boundary_worker" {
  role_name = "boundary-worker"

  policies = [vault_policy.boundary_worker.name]

  renewable = false
  ttl       = "2h"
}