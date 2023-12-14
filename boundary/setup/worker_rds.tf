data "aws_security_group" "database" {
  tags = {
    Business_Unit = local.name
    Purpose       = "database"
  }
}

module "boundary_worker_rds" {
  source  = "joatmon08/hcp/aws//modules/boundary-worker"
  version = "4.0.0"

  name                     = "${local.name}-boundary-worker-rds"
  boundary_addr            = local.url
  worker_prefix            = "rds-"
  worker_keypair_name      = local.boundary_key_pair_name
  worker_public_subnet_id  = local.public_subnets.0
  worker_security_group_id = data.aws_security_group.database.id
  worker_tags              = [local.name, "rds", "ingress"]
  vpc_id                   = local.vpc_id

  boundary_username = local.username
  boundary_password = local.password
}

resource "aws_security_group_rule" "allow_boundary_worker_to_database" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = module.boundary_worker_rds.security_group_id
  security_group_id        = data.aws_security_group.database.id
}