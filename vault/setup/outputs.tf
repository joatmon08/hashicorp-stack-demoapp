output "vault_kubernetes_auth_path" {
  value       = vault_auth_backend.kubernetes.path
  description = "Path for Kubernets auth method in Vault"
}

output "database_static_path" {
  value       = vault_mount.static.path
  description = "Path to static secrets related to database service"
}

output "database_secret_name" {
  value       = local.database_secret_name
  description = "Name of secret with database admin credentials"
}