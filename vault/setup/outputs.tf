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

output "application_token" {
  value     = vault_token.application.client_token
  sensitive = true
}