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
  common_name  = "Consul CA1 v1"
  key_type     = "rsa"
  key_bits     = "2048"
  ou           = "HashiConf Europe"
  organization = "HashiCorp"
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

resource "vault_mount" "consul_server_pki_int" {
  path                      = "consul/pki_int"
  type                      = "pki"
  description               = "PKI engine hosting intermediate CA2 v1 for Consul"
  default_lease_ttl_seconds = 3600
  max_lease_ttl_seconds     = 31536000
}

resource "vault_pki_secret_backend_intermediate_cert_request" "consul_server_pki_int" {
  depends_on   = [vault_mount.consul_server_pki_int]
  backend      = vault_mount.consul_server_pki_int.path
  type         = "internal"
  common_name  = "Consul CA2 v1"
  key_type     = "rsa"
  key_bits     = "2048"
  ou           = "HashiConf Europe"
  organization = "HashiCorp"
  country      = "US"
  locality     = "San Francisco"
  province     = "California"
}

resource "vault_pki_secret_backend_root_sign_intermediate" "consul_server_pki_int" {
  count = var.signed_cert ? 1 : 0
  depends_on = [
    vault_mount.consul_pki,
    vault_pki_secret_backend_intermediate_cert_request.consul_server_pki_int,
  ]
  backend              = vault_mount.consul_pki.path
  csr                  = vault_pki_secret_backend_intermediate_cert_request.consul_server_pki_int.csr
  common_name          = "Consul CA2 v1.1"
  exclude_cn_from_sans = true
  ou                   = "HashiConf Europe"
  organization         = "HashiCorp"
  country              = "US"
  locality             = "San Francisco"
  province             = "California"
  max_path_length      = 1
  ttl                  = 31536000
}

resource "vault_pki_secret_backend_intermediate_set_signed" "consul_server_pki_int" {
  count       = var.signed_cert ? 1 : 0
  depends_on  = [vault_pki_secret_backend_root_sign_intermediate.consul_server_pki_int]
  backend     = vault_mount.consul_server_pki_int.path
  certificate = var.signed_cert ? format("%s\n%s", vault_pki_secret_backend_root_sign_intermediate.consul_server_pki_int.0.certificate, file("../intermediate/ca.crt")) : null
}