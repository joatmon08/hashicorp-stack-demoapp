data "kubernetes_service_account" "vault_auth" {
  depends_on = [helm_release.vault]

  metadata {
    name = "vault"
  }
}

data "kubernetes_secret" "vault_auth" {
  depends_on = [helm_release.vault]

  metadata {
    name = data.kubernetes_service_account.vault_auth.default_secret_name
  }
}

resource "vault_auth_backend" "kubernetes" {
  depends_on = [helm_release.vault]
  type       = "kubernetes"
}

resource "vault_kubernetes_auth_backend_config" "kubernetes" {
  depends_on         = [helm_release.vault]
  backend            = vault_auth_backend.kubernetes.path
  kubernetes_host    = local.kubernetes_host
  kubernetes_ca_cert = data.kubernetes_secret.vault_auth.data["ca.crt"]
  token_reviewer_jwt = data.kubernetes_secret.vault_auth.data.token
}