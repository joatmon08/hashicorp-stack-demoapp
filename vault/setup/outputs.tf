output "vault_kubernetes_auth_path" {
  value       = vault_auth_backend.kubernetes.path
  description = "Path for Kubernets auth method in Vault"
}

output "boundary_worker_path" {
  value = vault_mount.boundary_worker.path
}

output "boundary_worker_token" {
  value     = vault_token.boundary_worker.client_token
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