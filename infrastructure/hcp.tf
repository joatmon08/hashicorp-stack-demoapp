
locals {
  route_table_ids               = concat(module.vpc.private_route_table_ids, module.vpc.public_route_table_ids)
  hcp_consul_security_group_ids = [module.eks.cluster_primary_security_group_id]
  datacenter                    = var.hcp_consul_datacenter == "" ? var.name : var.hcp_consul_datacenter
  ingress_consul_rules = [
    {
      description = "HCP Consul Server RPC"
      port        = 8300
      protocol    = "tcp"
    },
    {
      description = "Consul LAN Serf (tcp)"
      port        = 8301
      protocol    = "tcp"
    },
    {
      description = "Consul LAN Serf (udp)"
      port        = 8301
      protocol    = "udp"
    },
    {
      description = "Consul HTTP"
      port        = 80
      protocol    = "udp"
    },
    {
      description = "Consul HTTPS"
      port        = 443
      protocol    = "udp"
    }
  ]

  hcp_consul_security_groups = flatten([
    for _, sg in local.hcp_consul_security_group_ids : [
      for _, rule in local.ingress_consul_rules : {
        security_group_id = sg
        description       = rule.description
        port              = rule.port
        protocol          = rule.protocol
      }
    ]
  ])
}

module "hcp" {
  source                     = "joatmon08/hcp/aws"
  version                    = "1.0.1"
  hvn_cidr_block             = var.hcp_consul_cidr_block
  hvn_name                   = var.name
  hvn_region                 = var.region
  number_of_route_table_ids  = length(local.route_table_ids)
  route_table_ids            = local.route_table_ids
  vpc_cidr_block             = module.vpc.vpc_cidr_block
  vpc_id                     = module.vpc.vpc_id
  vpc_owner_id               = module.vpc.vpc_owner_id
  hcp_consul_name            = var.name
  hcp_consul_public_endpoint = var.hcp_consul_public_endpoint
  hcp_vault_name             = var.name
  hcp_vault_public_endpoint  = var.hcp_vault_public_endpoint
}
