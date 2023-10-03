data "aws_eks_cluster" "cluster" {
  name = local.eks_cluster_name
}

resource "boundary_target" "kubernetes" {
  type                     = "tcp"
  name                     = "kubernetes"
  description              = "Kubernetes API"
  scope_id                 = boundary_scope.apps["payments-app"].id
  address                  = replace(data.aws_eks_cluster.cluster.endpoint, "https://", "")
  session_connection_limit = 1
  default_port             = 443
  brokered_credential_source_ids = [
    boundary_credential_library_vault.application["payments-app"].id
  ]
}