resource "boundary_host_catalog_static" "database" {
  name        = "${var.business_unit}-database"
  description = "${var.business_unit} database"
  scope_id    = var.boundary_scope_id
}

resource "boundary_host_static" "database" {
  type            = "static"
  name            = "${var.business_unit}-database"
  description     = "${var.business_unit} database"
  address         = aws_db_instance.database.address
  host_catalog_id = boundary_host_catalog_static.database.id
}

resource "boundary_host_set_static" "database" {
  type            = "static"
  name            = "${var.business_unit}-database"
  description     = "Host set for ${var.business_unit} database"
  host_catalog_id = boundary_host_catalog_static.database.id
  host_ids        = [boundary_host_static.database.id]
}

resource "boundary_target" "database" {
  type                     = "tcp"
  name                     = "${var.business_unit}-database-postgres"
  description              = "${var.business_unit} Database Postgres Target"
  scope_id                 = var.boundary_scope_id
  session_connection_limit = 2
  default_port             = 5432
  host_source_ids = [
    boundary_host_set_static.database.id
  ]
}
