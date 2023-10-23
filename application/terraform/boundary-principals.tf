resource "boundary_user" "products" {
  for_each    = var.products_team
  name        = each.key
  description = "Products user: ${each.key}"
  account_ids = [boundary_account_password.products_user_acct[each.value].id]
  scope_id    = local.boundary_org_id
}

resource "random_password" "products_team" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "boundary_account_password" "products_user_acct" {
  for_each       = var.products_team
  name           = each.key
  description    = "User account for ${each.key}"
  login_name     = lower(each.key)
  password       = random_password.products_team.result
  auth_method_id = local.boundary_password_auth_method_id
}

resource "boundary_group" "apps" {
  for_each    = toset(keys(var.tfc_team_ids))
  name        = "apps-${each.value}"
  description = "App team access ${each.value}"
  member_ids  = [for user in boundary_user.products : user.id]
  scope_id    = boundary_scope.apps[each.value].id
}