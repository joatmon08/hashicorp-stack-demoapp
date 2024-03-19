resource "hcp_vault_secrets_app" "argocd" {
  app_name    = "argocd"
  description = "Secrets related to running Argo CD on Kubernetes"
}

resource "hcp_vault_secrets_secret" "argocd_repository" {
  count        = var.argocd_github_app_private_key != null ? 1 : 0
  app_name     = hcp_vault_secrets_app.argocd.app_name
  secret_name  = "ARGOCD_GITHUB_APP_PRIVATE_KEY"
  secret_value = base64decode(var.argocd_github_app_private_key)
}