output "consul_address" {
  value = data.hcp_consul_cluster.cluster.consul_public_endpoint_url
}

output "consul_token" {
  value     = hcp_consul_cluster_root_token.token.secret_id
  sensitive = true
}