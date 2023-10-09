resource "vault_github_auth_backend" "demo" {
  organization    = var.github_organization
  organization_id = var.github_organization_id
}
