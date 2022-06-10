resource "vault_kubernetes_auth_backend_role" "consul_server" {
  backend                          = local.vault_kubernetes_auth_path
  role_name                        = "consul-server"
  bound_service_account_names      = ["consul-server"]
  bound_service_account_namespaces = [var.consul_namespace]
  token_ttl                        = 86400
  token_policies = [
    vault_policy.consul_gossip.name,
    vault_policy.consul_cert.name,
    vault_policy.connect_ca.name,
    vault_policy.consul_bootstrap.name
  ]
}

resource "vault_kubernetes_auth_backend_role" "consul_client" {
  backend                          = local.vault_kubernetes_auth_path
  role_name                        = "consul-client"
  bound_service_account_names      = ["consul-client"]
  bound_service_account_namespaces = [var.consul_namespace]
  token_ttl                        = 86400
  token_policies = [
    vault_policy.consul_gossip.name
  ]
}

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

resource "vault_kubernetes_auth_backend_role" "consul_ca" {
  backend                          = local.vault_kubernetes_auth_path
  role_name                        = "consul-ca"
  bound_service_account_names      = ["*"]
  bound_service_account_namespaces = [var.consul_namespace]
  token_ttl                        = 86400
  token_policies = [
    vault_policy.ca_policy.name
  ]
}

resource "vault_kubernetes_auth_backend_role" "server_acl_init" {
  backend                          = local.vault_kubernetes_auth_path
  role_name                        = "consul-server-acl-init"
  bound_service_account_names      = ["consul-server-acl-init"]
  bound_service_account_namespaces = [var.consul_namespace]
  token_ttl                        = 86400
  token_policies = [
    vault_policy.consul_bootstrap.name
  ]
}

resource "vault_kubernetes_auth_backend_role" "consul_terraform_sync" {
  backend                          = local.vault_kubernetes_auth_path
  role_name                        = "consul-terraform-sync"
  bound_service_account_names      = ["consul-terraform-sync"]
  bound_service_account_namespaces = ["default"]
  token_ttl                        = 3600
  token_policies = [
    vault_policy.cts.name
  ]
}