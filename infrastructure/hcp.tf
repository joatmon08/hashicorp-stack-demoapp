locals {
  hcp_region      = var.hcp_region == "" ? var.region : var.hcp_region
  route_table_ids = concat(module.vpc.private_route_table_ids, module.vpc.public_route_table_ids)
  datacenter      = var.hcp_consul_datacenter == "" ? var.name : var.hcp_consul_datacenter
}

module "hcp" {
  source                        = "joatmon08/hcp/aws"
  version                       = "2.2.0"
  hvn_cidr_block                = var.hcp_cidr_block
  hvn_name                      = var.name
  hvn_region                    = local.hcp_region
  number_of_route_table_ids     = length(local.route_table_ids)
  route_table_ids               = local.route_table_ids
  vpc_cidr_block                = module.vpc.vpc_cidr_block
  vpc_id                        = module.vpc.vpc_id
  vpc_owner_id                  = module.vpc.vpc_owner_id
  hcp_consul_name               = var.name
  hcp_consul_public_endpoint    = var.hcp_consul_public_endpoint
  hcp_consul_security_group_ids = [module.eks.cluster_primary_security_group_id]
  hcp_vault_name                = var.name
  hcp_vault_public_endpoint     = var.hcp_vault_public_endpoint
}

resource "hcp_vault_cluster_admin_token" "cluster" {
  cluster_id = module.hcp.hcp_vault_id
}
