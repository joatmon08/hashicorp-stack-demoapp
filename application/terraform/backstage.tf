resource "vault_github_user" "backstage" {
  backend  = local.vault_github_auth_path
  user     = var.github_user
  policies = [vault_policy.tfc_secrets_engine["hashicups"].name]
}