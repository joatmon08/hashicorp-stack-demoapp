resource "hcp_vault_secrets_app" "argocd" {
  app_name    = "argocd"
  description = "Secrets related to running Argo CD on Kubernetes"
}

resource "hcp_vault_secrets_secret" "argocd_github_app_id" {
  count        = var.argocd_github_app.slug != null ? 1 : 0
  app_name     = hcp_vault_secrets_app.argocd.app_name
  secret_name  = "githubAppID"
  secret_value = var.argocd_github_app.id
}

resource "hcp_vault_secrets_secret" "argocd_github_app_installation_id" {
  count        = var.argocd_github_app.slug != null ? 1 : 0
  app_name     = hcp_vault_secrets_app.argocd.app_name
  secret_name  = "githubAppInstallationID"
  secret_value = var.argocd_github_app.installation_id
}

resource "hcp_vault_secrets_secret" "argocd_github_app_private_key" {
  count        = var.argocd_github_app.slug != null ? 1 : 0
  app_name     = hcp_vault_secrets_app.argocd.app_name
  secret_name  = "githubAppPrivateKey"
  secret_value = base64decode(var.argocd_github_app.private_key)
}

resource "hcp_vault_secrets_secret" "argocd_github_url" {
  count        = var.argocd_github_app.slug != null ? 1 : 0
  app_name     = hcp_vault_secrets_app.argocd.app_name
  secret_name  = "url"
  secret_value = var.argocd_github_app.url
}