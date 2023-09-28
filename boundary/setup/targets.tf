resource "boundary_target" "eks_nodes_ssh" {
  type                     = "tcp"
  name                     = "eks_nodes_ssh"
  description              = "EKS Nodes SSH target"
  scope_id                 = boundary_scope.core_infra.id
  ingress_worker_filter    = "\"eks\" in \"/tags/type\""
  egress_worker_filter     = "\"${local.name}\" in \"/tags/type\""
  session_connection_limit = 3
  default_port             = 22
  host_source_ids = [
    boundary_host_set_static.eks_nodes.id
  ]
}