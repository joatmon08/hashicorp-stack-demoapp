resource "vault_pki_secret_backend_role" "consul_server" {
  backend = var.vault_consul_pki_backend
  name    = "consul-server"
  max_ttl = 2592000
  allowed_domains = [
    "${var.consul_datacenter}.consul",
    "consul-server",
    "consul-server.${var.consul_namespace}",
    "consul-server.${var.consul_namespace}.svc"
  ]
  allow_subdomains   = true
  allow_bare_domains = true
  allow_localhost    = true
  generate_lease     = true
}

resource "vault_pki_secret_backend_config_urls" "consul_server" {
  backend = var.vault_consul_pki_backend
  issuing_certificates = [
    "${data.hcp_vault_cluster.cluster.vault_private_endpoint_url}/v1/${var.vault_consul_pki_backend}/ca"
  ]
  crl_distribution_points = [
    "${data.hcp_vault_cluster.cluster.vault_private_endpoint_url}/v1/${var.vault_consul_pki_backend}/crl"
  ]
}