data "kubernetes_service_account" "vault_auth" {
  depends_on = [helm_release.vault]

  metadata {
    name = "vault"
  }
}

resource "kubernetes_secret" "vault_auth" {
  depends_on = [helm_release.vault]
  metadata {
    name = "vault"
    annotations = {
      "kubernetes.io/service-account.name" = data.kubernetes_service_account.vault_auth.metadata.0.name
    }
  }

  type = "kubernetes.io/service-account-token"
}

resource "vault_auth_backend" "kubernetes" {
  depends_on = [helm_release.vault]
  type       = "kubernetes"
}

resource "vault_kubernetes_auth_backend_config" "kubernetes" {
  depends_on             = [helm_release.vault]
  backend                = vault_auth_backend.kubernetes.path
  kubernetes_host        = local.kubernetes_host
  kubernetes_ca_cert     = kubernetes_secret.vault_auth.data["ca.crt"]
  token_reviewer_jwt     = kubernetes_secret.vault_auth.data.token
  disable_iss_validation = "true"
}