resource "vault_pki_secret_backend_config_urls" "consul_connect" {
  count   = var.use_vault_root_ca ? 0 : 1
  backend = var.vault_consul_connect_pki_root_backend
  issuing_certificates = [
    "${local.hcp_vault_private_address}/v1/${var.vault_consul_connect_pki_root_backend}/ca"
  ]
  crl_distribution_points = [
    "${local.hcp_vault_private_address}/v1/${var.vault_consul_connect_pki_root_backend}/crl"
  ]
}