data "aws_availability_zones" "available" {
  state = "available"

  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

locals {
  subnets = cidrsubnets("10.0.0.0/16", 8, 8, 8, 8, 8, 8, 8, 8, 8)
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.1"

  name            = var.name
  cidr            = var.vpc_cidr_block
  azs             = data.aws_availability_zones.available.names
  private_subnets = slice(local.subnets, 0, 3)
  public_subnets  = slice(local.subnets, 3, 6)

  create_database_subnet_group       = true
  create_database_subnet_route_table = true
  database_subnets                   = slice(local.subnets, 6, 9)
  database_subnet_group_tags = {
    Purpose = "database"
  }

  manage_default_route_table = true
  default_route_table_tags   = { DefaultRouteTable = true }

  enable_nat_gateway   = true
  single_nat_gateway   = false
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.name}" = "shared"
    "kubernetes.io/role/elb"            = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.name}" = "shared"
    "kubernetes.io/role/internal-elb"   = "1"
  }
}

resource "aws_security_group" "database" {
  name        = "${var.name}-database"
  description = "Allow inbound traffic to database"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Allow inbound from VPC"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  ingress {
    description = "Allow inbound from HCP Vault"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.hcp_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.name}-database"
    Purpose = "database"
  }
}