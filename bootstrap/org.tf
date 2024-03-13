resource "tfe_organization" "demo" {
  allow_force_delete_workspaces = true
  name                          = var.tfc_organization
  email                         = var.email
}

data "tfe_github_app_installation" "gha_installation" {
  name = var.github_user
}

resource "tfe_organization_token" "demo" {
  organization = tfe_organization.demo.name
}