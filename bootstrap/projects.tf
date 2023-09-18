resource "tfe_project" "platform" {
  organization = tfe_organization.demo.name
  name         = "platform"
}

resource "tfe_project" "business_units" {
  for_each     = toset(var.business_units)
  name         = each.value
  organization = tfe_organization.demo.name
}

resource "tfe_team" "business_units" {
  for_each     = toset(var.business_units)
  name         = each.value
  organization = tfe_organization.demo.name
  visibility   = "organization"
}

resource "tfe_team_project_access" "business_units" {
  for_each   = toset(var.business_units)
  access     = "admin"
  team_id    = tfe_team.business_units[each.value].id
  project_id = tfe_project.business_units[each.value].id
}

