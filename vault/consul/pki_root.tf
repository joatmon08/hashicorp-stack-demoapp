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