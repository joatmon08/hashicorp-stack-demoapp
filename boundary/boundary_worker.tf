resource "tls_private_key" "boundary" {
  algorithm = "RSA"
}

resource "aws_key_pair" "boundary" {
  key_name   = var.name
  public_key = trimspace(tls_private_key.boundary.public_key_openssh)
}

module "boundary_worker" {
  depends_on = [module.vpc]
  source     = "joatmon08/boundary/aws//modules/hcp"
  version    = "0.4.0"

  name                = var.name
  boundary_cluster_id = split(".", replace(hcp_boundary_cluster.main.cluster_url, "https://", "", ))[0]
  worker_tags         = [var.name, "ingress"]
  vpc_id              = local.vpc_id
  key_pair_name       = aws_key_pair.boundary.key_name
  public_subnet_id    = local.public_subnets.0
  vault_addr          = local.vault_addr
  vault_namespace     = local.vault_namespace
  vault_token         = local.vault_token
  vault_path          = "boundary/worker"
}

resource "aws_security_group_rule" "allow_9202_worker" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.client_cidr_block
  security_group_id = module.boundary_worker.security_group.id
}