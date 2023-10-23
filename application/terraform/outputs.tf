output "consul_tgw_database_policy" {
  value = consul_acl_policy.terminating_gateway_database.name
}

output "boundary_scope_ids" {
  value = { for key, value in boundary_scope.apps : key => value.id }
}

output "boundary_credentials_store_ids" {
  value = { for key, value in boundary_credential_store_vault.application : key => value.id }
}

output "boundary_products_password" {
  value     = random_password.products_team.result
  sensitive = true
}

output "boundary_auth_method_id" {
  value = local.boundary_password_auth_method_id
}