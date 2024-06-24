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
    read_projects   = true
    read_workspaces = true
  }
}

resource "tfe_project" "business_units" {
  for_each     = toset(var.business_units)
  organization = tfe_organization.demo.name
  name         = each.value
}

resource "tfe_team_project_access" "business_units" {
  for_each   = toset(var.business_units)
  access     = "admin"
  team_id    = tfe_team.business_units[each.value].id
  project_id = tfe_project.business_units[each.value].id
}

resource "tfe_project_variable_set" "application_hcp" {
  for_each        = toset(var.business_units)
  variable_set_id = tfe_variable_set.hcp.id
  project_id      = tfe_project.business_units[each.value].id
}

resource "tfe_project_variable_set" "application_common" {
  for_each        = toset(var.business_units)
  variable_set_id = tfe_variable_set.applications.id
  project_id      = tfe_project.business_units[each.value].id
}