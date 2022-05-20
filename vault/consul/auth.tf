resource "vault_kubernetes_auth_backend_role" "consul_server" {
  backend                          = local.vault_kubernetes_auth_path
  role_name                        = "consul-server"
  bound_service_account_names      = ["consul-server"]
  bound_service_account_namespaces = [var.consul_namespace]
  token_ttl                        = 86400
  token_policies = [
    vault_policy.consul_gossip.name,
    vault_policy.consul_cert.name,
    vault_policy.connect_ca.name
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
  role_name                        = "server-acl-init"
  bound_service_account_names      = ["server-acl-init"]
  bound_service_account_namespaces = [var.consul_namespace]
  token_ttl                        = 86400
  token_policies = [
    vault_policy.consul_bootstrap.name
  ]
}
