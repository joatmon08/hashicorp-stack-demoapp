resource "boundary_scope" "apps" {
  for_each                 = toset(keys(var.tfc_team_ids))
  name                     = each.value
  description              = "Endpoints for ${each.value} team"
  scope_id                 = local.boundary_org_id
  auto_create_admin_role   = true
  auto_create_default_role = true
}

resource "boundary_role" "project_admin_products" {
  for_each       = toset(keys(var.tfc_team_ids))
  name           = "${each.value}_admin"
  description    = "Administrator role for ${each.value}"
  scope_id       = local.boundary_org_id
  grant_scope_id = boundary_scope.apps[each.value].id
  grant_strings = [
    "id=*;type=*;actions=*"
  ]
  principal_ids = [
    boundary_group.apps[each.value].id
  ]
}

resource "boundary_role" "org_readonly" {
  name          = "readonly-apps"
  description   = "Apps can read other projects"
  principal_ids = [for key, value in boundary_group.apps : value.id]
  grant_strings = [
    "id=*;type=*;actions=read",
    "id=*;type=target;actions=read,list,authorize-session",
    "id=*;type=session;actions=read,list"
  ]
  scope_id       = "global"
  grant_scope_id = local.boundary_org_id
}
