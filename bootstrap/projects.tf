resource "tfe_project" "platform" {
  organization = tfe_organization.demo.name
  name         = "platform"
}

resource "tfe_team" "business_units" {
  for_each     = toset(var.business_units)
  name         = each.value
  organization = tfe_organization.demo.name
  visibility   = "organization"
  organization_access {
    manage_workspaces = true
  }
}

resource "tfe_project" "hashicups" {
  organization = tfe_organization.demo.name
  name         = "hashicups"
}

resource "tfe_team_project_access" "hashicups" {
  access     = "admin"
  team_id    = tfe_team.business_units["hashicups"].id
  project_id = tfe_project.hashicups.id
}

resource "tfe_project_variable_set" "hashicups" {
  variable_set_id = tfe_variable_set.applications.id
  project_id      = tfe_project.hashicups.id
}