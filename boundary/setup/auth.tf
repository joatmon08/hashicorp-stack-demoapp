resource "boundary_auth_method" "password" {
  name        = "hashicups"
  description = "Password auth method for HashiCups org"
  type        = "password"
  scope_id    = boundary_scope.org.id
}
