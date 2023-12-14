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

resource "vault_token" "boundary_worker_ssh" {
  policies          = [vault_policy.boundary_worker_ssh.name, vault_policy.boundary_credentials_store.name]
  no_default_policy = true
  no_parent         = true
  ttl               = "3d"
  explicit_max_ttl  = "6d"
  period            = "3d"
  renewable         = true
  num_uses          = 0
}