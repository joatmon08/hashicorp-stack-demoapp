data "aws_security_group" "boundary_worker" {
  tags = {
    Business_Unit = local.name
    Purpose       = "boundary"
  }
}

module "boundary_worker_eks" {
  source  = "joatmon08/boundary/aws//modules/hcp"
  version = "0.5.1"

  name                     = "${local.name}-boundary-worker-eks"
  boundary_cluster_id      = split(".", replace(local.url, "https://", "", ))[0]
  worker_tags              = [local.name, "eks", "ingress"]
  vpc_id                   = local.vpc_id
  key_pair_name            = local.boundary_key_pair_name
  public_subnet_id         = local.public_subnets.0
  vault_addr               = local.vault_addr
  vault_namespace          = local.vault_namespace
  vault_token              = local.vault_worker_token
  vault_path               = "boundary/worker"
  worker_security_group_id = data.aws_security_group.boundary_worker.id
}

resource "aws_security_group_rule" "allow_ssh_worker" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.client_cidr_block
  security_group_id = data.aws_security_group.boundary_worker.id
}

resource "aws_security_group_rule" "allow_boundary_worker_to_eks_ssh" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = data.aws_security_group.boundary_worker.id
  security_group_id        = local.eks_cluster_security_group_id
}