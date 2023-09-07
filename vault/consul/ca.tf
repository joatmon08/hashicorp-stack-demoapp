resource "vault_token_auth_backend_role" "connect_ca_hcp" {
  role_name           = "connect-ca-hcp"
  allowed_policies    = [vault_policy.connect_ca_hcp.name]
  disallowed_policies = ["default"]
  orphan              = true
  token_period        = "172800"
  renewable           = true
  token_num_uses      = 0
}

resource "vault_token" "connect_ca_hcp" {
  role_name = vault_token_auth_backend_role.connect_ca_hcp.role_name
  policies  = [vault_policy.connect_ca_hcp.name]
}

resource "consul_certificate_authority" "connect" {
  connect_provider = "vault"

  config_json = jsonencode({
    Address             = local.hcp_vault_private_address
    Token               = vault_token.connect_ca_hcp.client_token
    RootPKIPath         = "connect_root"
    IntermediatePKIPath = "connect_inter"
    Namespace           = local.hcp_vault_namespace
  })
}

check "connect_ca" {
  data "http" "certs" {
    url = "${local.hcp_consul_public_address}/v1/connect/ca/configuration"
    request_headers = {
      X-Consul-Token = local.hcp_consul_token
    }
  }

  assert {
    condition     = jsondecode(data.http.certs.response_body).Provider == "vault"
    error_message = "Connect CA is not configured to use HCP Vault"
  }
}