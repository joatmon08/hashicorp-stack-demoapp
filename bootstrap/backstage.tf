resource "tfe_team" "backstage" {
  name         = "backstage"
  organization = tfe_organization.demo.name
  visibility   = "organization"
  organization_access {
    manage_workspaces = true
    manage_projects   = true
  }
}