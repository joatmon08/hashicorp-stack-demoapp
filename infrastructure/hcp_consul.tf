locals {
  datacenter = var.hcp_consul_datacenter == "" ? var.name : var.hcp_consul_datacenter
}

module "aws_hcp_consul" {
  source  = "hashicorp/hcp-consul/aws"
  version = "0.12.1"

  hvn                = hcp_hvn.main
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = concat(module.vpc.private_subnets, module.vpc.database_subnets)
  route_table_ids    = concat(module.vpc.private_route_table_ids, module.vpc.database_route_table_ids)
  security_group_ids = [module.eks.cluster_primary_security_group_id]
}

data "hcp_consul_versions" "default" {}

resource "hcp_consul_cluster" "main" {
  cluster_id      = var.name
  hvn_id          = hcp_hvn.main.hvn_id
  public_endpoint = var.hcp_consul_public_endpoint
  tier            = var.hcp_consul_tier
  datacenter      = local.datacenter

  ip_allowlist {
    address     = "0.0.0.0/0"
    description = "Allow TFC to automate"
  }

}

resource "hcp_consul_cluster_root_token" "token" {
  cluster_id = hcp_consul_cluster.main.id
}