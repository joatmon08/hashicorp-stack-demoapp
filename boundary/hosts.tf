resource "boundary_host_catalog_static" "products_database" {
  name        = "products_database"
  description = "Products database"
  scope_id    = boundary_scope.products_infra.id
}

resource "boundary_host_static" "products_database" {
  type            = "static"
  name            = "products_database"
  description     = "products database"
  address         = local.products_database_target_address
  host_catalog_id = boundary_host_catalog_static.products_database.id
}

resource "boundary_host_set_static" "products_database" {
  type            = "static"
  name            = "products_database"
  description     = "Host set for Product Database"
  host_catalog_id = boundary_host_catalog_static.products_database.id
  host_ids        = [boundary_host_static.products_database.id]
}

resource "boundary_host_catalog_static" "products_frontend" {
  count       = var.products_frontend_address != "" ? 1 : 0
  name        = "products_frontend"
  description = "Products frontend"
  scope_id    = boundary_scope.products_infra.id
}

resource "boundary_host_static" "products_frontend" {
  count           = var.products_frontend_address != "" ? 1 : 0
  type            = "static"
  name            = "products_frontend"
  description     = "products frontend"
  address         = var.products_frontend_address
  host_catalog_id = boundary_host_catalog_static.products_frontend.0.id
}

resource "boundary_host_set_static" "products_frontend" {
  count           = var.products_frontend_address != "" ? 1 : 0
  type            = "static"
  name            = "products_frontend"
  description     = "Host set for Product Frontend"
  host_catalog_id = boundary_host_catalog_static.products_frontend.0.id
  host_ids        = [boundary_host_static.products_frontend.0.id]
}