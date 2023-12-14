output "vault_kubernetes_auth_path" {
  value       = vault_auth_backend.kubernetes.path
  description = "Path for Kubernets auth method in Vault"
}

output "boundary_worker_ssh" {
  value = {
    path   = "${vault_kv_secret_v2.boundary_worker_keypair.mount}/${vault_kv_secret_v2.boundary_worker_keypair.name}"
    policy = vault_policy.boundary_worker_ssh.name
    token  = vault_token.boundary_worker_ssh.client_token
  }
  sensitive = true
}

output "vault_kubernetes_secrets_engine_path" {
  value = vault_kubernetes_secret_backend.boundary.path
}

output "boundary_cluster_role" {
  value = local.boundary_access_cluster_role
}

output "vault_github_auth_path" {
  value = vault_github_auth_backend.demo.path
}