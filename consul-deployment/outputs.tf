output "hcp_consul_token" {
  value     = hcp_consul_cluster_root_token.token.secret_id
  sensitive = true
}