output "hcp_vault_token" {
  value     = hcp_vault_cluster_admin_token.cluster.token
  sensitive = true
}