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
  version = "3.14.0"

  name             = var.name
  cidr             = var.vpc_cidr_block
  azs              = data.aws_availability_zones.available.names
  private_subnets  = slice(local.subnets, 0, 3)
  public_subnets   = slice(local.subnets, 3, 6)
  database_subnets = slice(local.subnets, 6, 9)

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
