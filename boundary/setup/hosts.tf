resource "boundary_host_catalog_static" "eks_nodes" {
  name        = "eks-nodes"
  description = "EKS nodes for operations team"
  scope_id    = boundary_scope.core_infra.id
}

resource "boundary_host_static" "eks_nodes" {
  for_each        = local.eks_target_ips
  type            = "static"
  name            = each.value
  description     = "EKS Node #${each.value}"
  address         = each.key
  host_catalog_id = boundary_host_catalog_static.eks_nodes.id
}

resource "boundary_host_set_static" "eks_nodes" {
  type            = "static"
  name            = "eks-nodes"
  description     = "Host set for EKS nodes"
  host_catalog_id = boundary_host_catalog_static.eks_nodes.id
  host_ids        = [for host in boundary_host_static.eks_nodes : host.id]
}