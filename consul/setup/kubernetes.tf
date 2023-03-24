locals {
  default_values = templatefile("templates/values.yaml", {
    CONSUL_DATACENTER            = local.consul_datacenter
    CONSUL_SERVER_ROLE           = local.roles.consul_server
    CONSUL_CLIENT_ROLE           = local.roles.consul_client
    CONSUL_CA_ROLE               = local.roles.consul_ca
    SERVER_ACL_INIT_ROLE         = local.roles.server_acl_init
    VAULT_ADDR                   = local.vault_addr
    VAULT_NAMESPACE              = local.vault_namespace
    KUBERNETES_AUTH_METHOD_PATH  = local.paths.kubernetes_auth_method
    CONSUL_PKI_PATH              = local.paths.consul_pki
    CONSUL_STATIC_PATH           = local.paths.consul_static
    CONSUL_CONNECT_PKI_PATH_ROOT = local.paths.consul_connect_root
    CONSUL_CONNECT_PKI_PATH_INT  = local.paths.consul_connect_int
  })
}
resource "helm_release" "consul" {
  count = var.use_hcp_consul ? 0 : 1
  name  = "consul"

  repository = "https://helm.releases.hashicorp.com"
  chart      = "consul"
  version    = var.consul_helm_version

  values = [
    var.consul_values != null ? base64decode(var.consul_values) : local.default_values
  ]

  set {
    name  = "global.image"
    value = var.consul_version
  }
}