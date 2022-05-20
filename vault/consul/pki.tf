resource "vault_pki_secret_backend_role" "consul_server" {
  backend            = var.vault_consul_pki_backend
  name               = "consul-server"
  max_ttl            = 2592000
  allowed_domains    = ["${var.consul_datacenter}.consul", "consul-server", "consul-server.${var.consul_namespace}", "consul-server.${var.consul_namespace}.svc"]
  allow_subdomains   = true
  allow_bare_domains = true
  allow_localhost    = true
  generate_lease     = true
}

resource "vault_pki_secret_backend_config_urls" "consul_server" {
  backend = var.vault_consul_pki_backend
  issuing_certificates = [
    "${data.hcp_vault_cluster.cluster.vault_private_endpoint_url}/v1/pki/ca"
  ]
  crl_distribution_points = [
    "${data.hcp_vault_cluster.cluster.vault_private_endpoint_url}/v1/pki/crl"
  ]
}

resource "vault_policy" "ca_policy" {
  name = "ca-policy"

  policy = <<EOT
path "${var.vault_consul_pki_backend}/cert/ca" {
  capabilities = ["read"]
}
EOT
}

resource "vault_policy" "consul_cert" {
  name = "consul-server"

  policy = <<EOT
path "${var.vault_consul_pki_backend}/issue/${vault_pki_secret_backend_role.consul_server.name}"
{
  capabilities = ["create","update"]
}
EOT
}

resource "vault_policy" "connect_ca" {
  name = "connect-ca"

  policy = <<EOT
path "/sys/mounts" {
  capabilities = [ "read" ]
}
path "/sys/mounts/connect_root" {
  capabilities = [ "create", "read", "update", "delete", "list" ]
}
path "/sys/mounts/${var.consul_datacenter}/connect_inter" {
  capabilities = [ "create", "read", "update", "delete", "list" ]
}
path "/connect_root/*" {
  capabilities = [ "create", "read", "update", "delete", "list" ]
}
path "/${var.consul_datacenter}/connect_inter/*" {
  capabilities = [ "create", "read", "update", "delete", "list" ]
}
EOT
}