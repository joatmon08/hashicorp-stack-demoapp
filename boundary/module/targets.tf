resource "boundary_target" "eks_nodes_ssh" {
  type                     = "tcp"
  name                     = "eks_nodes_ssh"
  description              = "EKS Nodes SSH target"
  scope_id                 = boundary_scope.core_infra.id
  session_connection_limit = -1
  default_port             = 22
  host_set_ids = [
    boundary_host_set.eks_nodes.id
  ]
}