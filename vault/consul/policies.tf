resource "vault_policy" "consul_api_gateway" {
  name = "consul-api-gateway"

  policy = <<EOT
path "${local.consul_gateway_pki_backend}/issue/${vault_pki_secret_backend_role.consul_gateway.name}"
{
  capabilities = ["create","update"]
}

path "${local.consul_gateway_pki_backend}/sign/${vault_pki_secret_backend_role.consul_gateway.name}"
{
  capabilities = ["create","update"]
}
EOT
}

resource "vault_policy" "connect_ca_hcp" {
  name = "connect-ca-hcp"

  policy = <<EOT
path "${var.vault_consul_connect_pki_root_backend}/root/sign-self-issued" {
  capabilities = [ "sudo", "update" ]
}

path "auth/token/renew-self" {
  capabilities = [ "update" ]
}

path "auth/token/lookup-self" {
  capabilities = [ "read" ]
}

path "/sys/mounts" {
  capabilities = [ "read" ]
}

path "/sys/mounts/${var.vault_consul_connect_pki_root_backend}" {
  capabilities = [ "create", "read", "update", "delete", "list" ]
}

path "/sys/mounts/${var.vault_consul_connect_pki_int_backend}" {
  capabilities = [ "create", "read", "update", "delete", "list" ]
}

path "/sys/mounts/${var.vault_consul_connect_pki_int_backend}/tune" {
  capabilities = [ "create", "read", "update", "delete", "list" ]
}

path "/${var.vault_consul_connect_pki_root_backend}/*" {
  capabilities = [ "create", "read", "update", "delete", "list" ]
}

path "/${var.vault_consul_connect_pki_int_backend}/*" {
  capabilities = [ "create", "read", "update", "delete", "list" ]
}
EOT
}