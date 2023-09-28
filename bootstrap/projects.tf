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
    manage_vcs_settings = true
  }
}