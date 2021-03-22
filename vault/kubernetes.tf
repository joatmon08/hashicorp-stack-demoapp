data "kubernetes_service_account" "vault_auth" {
  metadata {
    name = "vault"
  }
}

data "kubernetes_secret" "vault_auth" {
  metadata {
    name = data.kubernetes_service_account.vault_auth.default_secret_name
  }
}

resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
}

resource "vault_kubernetes_auth_backend_config" "kubernetes" {
  backend            = vault_auth_backend.kubernetes.path
  kubernetes_host    = var.kubernetes_host
  kubernetes_ca_cert = data.kubernetes_secret.vault_auth.data["ca.crt"]
  token_reviewer_jwt = data.kubernetes_secret.vault_auth.data.token
}

resource "vault_kubernetes_auth_backend_role" "product" {
  count                            = var.postgres_hostname != "" ? 1 : 0
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "product"
  bound_service_account_names      = ["product"]
  bound_service_account_namespaces = ["default"]
  token_ttl                        = 3600
  token_policies                   = [vault_policy.product.0.name]
}