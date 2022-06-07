locals {
  consul_gateway_pki_backend = var.vault_consul_gateway_pki_int_backend
}

resource "vault_pki_secret_backend_role" "consul_gateway" {
  backend          = local.consul_gateway_pki_backend
  name             = "consul-api-gateway"
  max_ttl          = 2592000
  allowed_uri_sans = ["spiffe://hostname/*"]
  require_cn       = false
}

resource "vault_pki_secret_backend_config_urls" "consul_gateway" {
  backend = local.consul_gateway_pki_backend
  issuing_certificates = [
    "${local.hcp_vault_private_address}/v1/${local.consul_gateway_pki_backend}/ca"
  ]
  crl_distribution_points = [
    "${local.hcp_vault_private_address}/v1/${local.consul_gateway_pki_backend}/crl"
  ]
}