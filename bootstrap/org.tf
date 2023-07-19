resource "tfe_organization" "demo" {
  allow_force_delete_workspaces = true
  name                          = var.tfc_organization
  email                         = var.email
}

resource "tfe_oauth_client" "github" {
  name             = "github"
  organization     = tfe_organization.demo.name
  api_url          = "https://api.github.com"
  http_url         = "https://github.com"
  oauth_token      = var.github_token
  service_provider = "github"
}