data "aws_security_group" "boundary_worker" {
  tags = {
    Business_Unit = local.name
    Purpose       = "boundary"
  }
}

module "boundary_worker_eks" {
  source  = "joatmon08/hcp/aws//modules/boundary-worker"
  version = "4.0.0"

  name                     = "${local.name}-boundary-worker-eks"
  boundary_addr            = local.url
  worker_prefix            = "eks-"
  worker_keypair_name      = local.boundary_key_pair_name
  worker_public_subnet_id  = local.public_subnets.0
  worker_security_group_id = data.aws_security_group.boundary_worker.id
  worker_tags              = [local.name, "eks", "ingress"]
  vpc_id                   = local.vpc_id

  boundary_username = local.username
  boundary_password = local.password
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