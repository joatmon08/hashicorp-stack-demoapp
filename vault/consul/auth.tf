resource "vault_kubernetes_auth_backend_role" "consul_api_gateway" {
  backend                          = local.vault_kubernetes_auth_path
  role_name                        = "consul-api-gateway"
  bound_service_account_names      = ["consul-api-gateway", "cert-manager"]
  bound_service_account_namespaces = [var.consul_namespace]
  token_ttl                        = 86400
  token_policies = [
    vault_policy.consul_api_gateway.name
  ]
}