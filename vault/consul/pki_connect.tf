resource "vault_pki_secret_backend_config_urls" "consul_connect" {
  count   = var.use_vault_root_ca ? 0 : 1
  backend = var.vault_consul_connect_pki_root_backend
  issuing_certificates = [
    "${data.hcp_vault_cluster.cluster.vault_private_endpoint_url}/v1/${var.vault_consul_connect_pki_root_backend}/ca"
  ]
  crl_distribution_points = [
    "${data.hcp_vault_cluster.cluster.vault_private_endpoint_url}/v1/${var.vault_consul_connect_pki_root_backend}/crl"
  ]
}

resource "vault_pki_secret_backend_role" "consul_connect" {
  backend = var.vault_consul_connect_pki_root_backend
  name    = "consul-server"
  max_ttl = 2592000
  allowed_domains = [
    "example.com"
  ]
  allow_subdomains   = true
  allow_bare_domains = true
  allow_localhost    = true
  generate_lease     = true
}
