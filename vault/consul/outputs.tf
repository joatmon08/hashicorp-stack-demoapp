output "paths" {
  value = {
    kubernetes_auth_method = local.vault_kubernetes_auth_path
    consul_gateway_pki     = local.consul_gateway_pki_backend
    consul_connect_root    = var.vault_consul_connect_pki_root_backend
    consul_connect_int     = var.vault_consul_connect_pki_int_backend
    consul_gateway_root    = var.vault_consul_connect_pki_root_backend
  }
}

output "consul_api_gateway_allowed_domain" {
  value = var.consul_api_gateway_allowed_domain
}