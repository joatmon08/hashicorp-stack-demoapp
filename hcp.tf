
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

resource "hcp_hvn" "hvn" {
  hvn_id         = var.name
  cloud_provider = "aws"
  region         = var.region
  cidr_block     = var.hcp_consul_cidr_block
}

resource "hcp_consul_cluster" "consul" {
  hvn_id          = hcp_hvn.hvn.hvn_id
  datacenter      = local.datacenter
  cluster_id      = var.name
  tier            = "development"
  public_endpoint = var.hcp_consul_public_endpoint
}

resource "hcp_aws_network_peering" "peer" {
  hvn_id              = hcp_hvn.hvn.hvn_id
  peer_vpc_id         = module.vpc.vpc_id
  peer_account_id     = module.vpc.vpc_owner_id
  peer_vpc_region     = var.region
  peer_vpc_cidr_block = module.vpc.vpc_cidr_block
}

resource "aws_vpc_peering_connection_accepter" "hvn" {
  vpc_peering_connection_id = hcp_aws_network_peering.peer.provider_peering_id
  auto_accept               = true
  tags                      = var.tags
}

resource "aws_route" "hvn" {
  count                     = length(local.route_table_ids)
  route_table_id            = local.route_table_ids[count.index]
  destination_cidr_block    = var.hcp_consul_cidr_block
  vpc_peering_connection_id = hcp_aws_network_peering.peer.provider_peering_id
}

resource "aws_security_group_rule" "hcp_consul" {
  count             = length(local.hcp_consul_security_groups)
  description       = local.hcp_consul_security_groups[count.index].description
  protocol          = local.hcp_consul_security_groups[count.index].protocol
  security_group_id = local.hcp_consul_security_groups[count.index].security_group_id
  cidr_blocks       = [var.hcp_consul_cidr_block]
  from_port         = local.hcp_consul_security_groups[count.index].port
  to_port           = local.hcp_consul_security_groups[count.index].port
  type              = "ingress"
}
