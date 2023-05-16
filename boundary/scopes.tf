resource "boundary_scope" "org" {
  scope_id    = "global"
  name        = "hashicups"
  description = "HashiCups scope"
  auto_create_default_role = true
  auto_create_admin_role   = true
}

// create a project for core infrastructure
resource "boundary_scope" "core_infra" {
  name                     = "core_infra"
  description              = "Operations infrastructure project"
  scope_id                 = boundary_scope.org.id
  auto_create_admin_role   = true
  auto_create_default_role = true
}

// create a project for products infrastructure
resource "boundary_scope" "products_infra" {
  name                     = "products_infra"
  description              = "Products infrastructure project"
  scope_id                 = boundary_scope.org.id
  auto_create_admin_role   = true
  auto_create_default_role = true
}

