resource "boundary_host_catalog" "eks_nodes" {
  name        = "eks_nodes"
  description = "EKS nodes for operations team"
  type        = "static"
  scope_id    = boundary_scope.core_infra.id
}

resource "boundary_host" "eks_nodes" {
  for_each        = var.target_ips
  type            = "static"
  name            = "eks_nodes_${each.value}"
  description     = "EKS Node #${each.value}"
  address         = each.key
  host_catalog_id = boundary_host_catalog.eks_nodes.id
}

resource "boundary_host_set" "eks_nodes" {
  type            = "static"
  name            = "eks_nodes"
  description     = "Host set for EKS nodes"
  host_catalog_id = boundary_host_catalog.eks_nodes.id
  host_ids        = [for host in boundary_host.eks_nodes : host.id]
}
