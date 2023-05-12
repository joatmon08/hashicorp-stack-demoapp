locals {
  datacenter = var.hcp_consul_datacenter == "" ? var.name : var.hcp_consul_datacenter
}

module "aws_hcp_consul" {
  source  = "hashicorp/hcp-consul/aws"
  version = "0.12.1"

  hvn                = hcp_hvn.main
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.public_subnets
  route_table_ids    = module.vpc.public_route_table_ids
  security_group_ids = [module.eks.cluster_primary_security_group_id]
}

resource "hcp_consul_cluster" "main" {
  cluster_id      = var.name
  hvn_id          = hcp_hvn.main.hvn_id
  public_endpoint = var.hcp_consul_public_endpoint
  tier            = var.hcp_consul_tier
  datacenter      = local.datacenter

  ip_allowlist {
    address     = var.client_cidr_block.0
    description = "Allow Client CIDR Block"
  }

}

resource "hcp_consul_cluster_root_token" "token" {
  cluster_id = hcp_consul_cluster.main.id
}