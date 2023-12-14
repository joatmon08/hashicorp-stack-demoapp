resource "vault_mount" "boundary_worker" {
  path        = "boundary/worker"
  type        = "kv"
  options     = { version = "2" }
  description = "Boundary worker tokens"
}

resource "vault_kv_secret_v2" "boundary_worker_keypair" {
  mount               = vault_mount.boundary_worker.path
  name                = "ssh"
  delete_all_versions = true
  data_json = jsonencode(
    {
      private_key = local.boundary_worker_ssh
      username    = var.boundary_worker_username
    }
  )
}

data "vault_policy_document" "boundary_worker_ssh" {
  rule {
    path         = "${vault_kv_secret_v2.boundary_worker_keypair.mount}/${vault_kv_secret_v2.boundary_worker_keypair.name}"
    capabilities = ["read", "list"]
    description  = "Get SSH keys for Boundary worker"
  }
}

resource "vault_policy" "boundary_worker_ssh" {
  name   = "boundary-worker-ssh"
  policy = data.vault_policy_document.boundary_worker_ssh.hcl
}

resource "vault_token_auth_backend_role" "boundary_worker_ssh" {
  role_name              = "boundary-worker-ssh"
  allowed_policies       = [vault_policy.boundary_worker_ssh.name]
  disallowed_policies    = ["default"]
  orphan                 = true
  token_period           = "86400"
  renewable              = true
  token_explicit_max_ttl = "115200"
}

resource "vault_token" "boundary_worker_ssh" {
  role_name = vault_token_auth_backend_role.boundary_worker_ssh.role_name
  policies  = [vault_policy.boundary_worker_ssh.name]
}