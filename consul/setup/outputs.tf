data "kubernetes_service" "consul" {
  metadata {
    name = "consul-ui"
  }
}

output "consul_address" {
    value = "https://${data.kubernetes_service.consul.status.load_balancer.ingress.0.hostname}"
}

output "consul_token" {
    
}