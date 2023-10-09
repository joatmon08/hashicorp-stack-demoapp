resource "vault_github_auth_backend" "demo" {
  organization = var.github_organization
}
