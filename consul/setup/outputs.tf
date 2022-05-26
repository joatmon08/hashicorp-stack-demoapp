data "kubernetes_service" "consul" {
  depends_on = [
    helm_release.consul
  ]
  count = var.use_hcp_consul ? 0 : 1
  metadata {
    name = "consul-ui"
  }
}

output "consul_address" {
  value = var.use_hcp_consul ? data.hcp_consul_cluster.cluster.consul_public_endpoint_url : "https://${data.kubernetes_service.consul.0.status.0.load_balancer.0.ingress.0.hostname}"
}

data "vault_generic_secret" "consul_token" {
  depends_on = [
    helm_release.consul
  ]
  count = var.use_hcp_consul ? 0 : 1
  path  = "${local.paths.consul_static}/bootstrap"
}

output "consul_token" {
  value     = var.use_hcp_consul ? hcp_consul_cluster_root_token.token.secret_id : data.vault_generic_secret.consul_token.0.data.token
  sensitive = true
}