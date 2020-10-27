module "hcp" {
  count                         = var.peering_connection_has_been_added_to_hvn ? 1 : 0
  source                        = "joatmon08/hcp/aws"
  version                       = "0.1.0"
  hcp_consul_security_group_ids = [module.eks.cluster_primary_security_group_id]
  hvn_cidr_block                = var.hcp_consul_cidr_block
  route_table_ids               = concat(module.vpc.private_route_table_ids, module.vpc.public_route_table_ids)
  vpc_id                        = module.vpc.vpc_id
}