resource "vault_mount" "consul_pki" {
  path                      = "consul/pki"
  type                      = "pki"
  description               = "PKI engine hosting intermediate CA for Consul"
  default_lease_ttl_seconds = 31536000
  max_lease_ttl_seconds     = 94608000
}

resource "vault_pki_secret_backend_intermediate_cert_request" "consul_pki" {
  depends_on   = [vault_mount.consul_pki]
  backend      = vault_mount.consul_pki.path
  type         = "internal"
  common_name  = "Consul CA"
  key_type     = "rsa"
  key_bits     = "2048"
  ou           = "HashiConf Europe"
  organization = "HashiConf"
  country      = "US"
  locality     = "San Francisco"
  province     = "California"
}

resource "local_file" "csr" {
  filename = "../intermediate/ca.csr"
  content  = vault_pki_secret_backend_intermediate_cert_request.consul_pki.csr
}

resource "vault_pki_secret_backend_intermediate_set_signed" "consul_pki" {
  count   = var.signed_cert ? 1 : 0
  backend = vault_mount.consul_pki.path

  certificate = var.signed_cert ? file("../intermediate/ca.crt") : null
}