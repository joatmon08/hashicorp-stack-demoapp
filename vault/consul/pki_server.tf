resource "vault_mount" "consul_pki" {
  count                     = var.use_vault_root_ca ? 1 : 0
  path                      = var.vault_consul_pki_root_backend
  type                      = "pki"
  description               = "PKI engine hosting root CA for Consul"
  default_lease_ttl_seconds = 31536000
  max_lease_ttl_seconds     = 94608000
}

resource "vault_pki_secret_backend_root_cert" "consul" {
  count        = var.use_vault_root_ca ? 1 : 0
  depends_on   = [vault_mount.consul_pki]
  backend      = vault_mount.consul_pki.0.path
  type         = "internal"
  common_name  = "Consul CA Root"
  ttl          = "31536000"
  ou           = "HashiConf Europe"
  organization = "HashiCorp"
  country      = "US"
  locality     = "San Francisco"
  province     = "California"
}

locals {
  consul_pki_backend = var.use_vault_root_ca ? vault_mount.consul_pki.0.path : var.vault_consul_pki_int_backend
}

resource "vault_pki_secret_backend_role" "consul_server" {
  backend = local.consul_pki_backend
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
  backend = local.consul_pki_backend
  issuing_certificates = [
    "${local.hcp_vault_private_address}/v1/${local.consul_pki_backend}/ca"
  ]
  crl_distribution_points = [
    "${local.hcp_vault_private_address}/v1/${local.consul_pki_backend}/crl"
  ]
}