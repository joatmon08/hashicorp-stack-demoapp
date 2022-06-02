locals {
  consul_gateway_pki_backend = var.vault_consul_gateway_pki_int_backend
}

resource "vault_pki_secret_backend_role" "consul_gateway" {
  backend            = local.consul_gateway_pki_backend
  name               = "consul-api-gateway"
  max_ttl            = 2592000
  allowed_domains    = ["*"]
  allow_subdomains   = true
  allow_bare_domains = true
  allow_localhost    = true
  generate_lease     = true
}

resource "vault_pki_secret_backend_config_urls" "consul_gateway" {
  backend = local.consul_gateway_pki_backend
  issuing_certificates = [
    "${data.hcp_vault_cluster.cluster.vault_private_endpoint_url}/v1/${local.consul_gateway_pki_backend}/ca"
  ]
  crl_distribution_points = [
    "${data.hcp_vault_cluster.cluster.vault_private_endpoint_url}/v1/${local.consul_gateway_pki_backend}/crl"
  ]
}