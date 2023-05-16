resource "boundary_target" "products_database_postgres" {
  type                     = "tcp"
  name                     = "products_database_postgres"
  description              = "Products Database Postgres Target"
  scope_id                 = boundary_scope.products_infra.id
  session_connection_limit = 2
  default_port             = 5432
  host_source_ids = [
    boundary_host_set_static.products_database.id
  ]
}

resource "boundary_target" "products_frontend" {
  count                    = var.products_frontend_address != "" ? 1 : 0
  type                     = "tcp"
  name                     = "products_frontend"
  description              = "Products Frontend Target"
  scope_id                 = boundary_scope.products_infra.id
  session_connection_limit = -1
  default_port             = 80
  host_source_ids = [
    boundary_host_set_static.products_frontend.0.id
  ]
}