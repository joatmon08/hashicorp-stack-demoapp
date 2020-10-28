data "kubernetes_secret" "vault_auth" {
  metadata {
    name = "vault-auth"
  }
}

resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
}

resource "vault_kubernetes_auth_backend_config" "kubernetes" {
  backend            = vault_auth_backend.kubernetes.path
  kubernetes_host    = var.kubernetes_host
  kubernetes_ca_cert = base64decode(var.kubernetes_ca_cert)
  token_reviewer_jwt = data.kubernetes_secret.vault_auth.data.token
}

resource "vault_kubernetes_auth_backend_role" "products" {
  count                            = var.postgres_hostname != "" ? 1 : 0
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "products"
  bound_service_account_names      = ["products"]
  bound_service_account_namespaces = ["default"]
  token_ttl                        = 3600
  token_policies                   = [vault_policy.products.0.name]
}