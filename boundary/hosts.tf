resource "boundary_host_catalog_static" "eks_nodes" {
  name        = "eks_nodes"
  description = "EKS nodes for operations team"
  scope_id    = boundary_scope.core_infra.id
}

resource "boundary_host_static" "eks_nodes" {
  for_each        = local.eks_target_ips
  type            = "static"
  name            = "eks_nodes_${each.value}"
  description     = "EKS Node #${each.value}"
  address         = each.key
  host_catalog_id = boundary_host_catalog_static.eks_nodes.id
}

resource "boundary_host_set_static" "eks_nodes" {
  type            = "static"
  name            = "eks_nodes"
  description     = "Host set for EKS nodes"
  host_catalog_id = boundary_host_catalog_static.eks_nodes.id
  host_ids        = [for host in boundary_host_static.eks_nodes : host.id]
}

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