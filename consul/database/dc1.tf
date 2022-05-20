# locals {
#   consul_dc_name = "consul-dc1"
# }

# resource "consul_service" "dc" {
#   count = var.consul_dc_addr != "" ? 1 : 0
#   name  = local.consul_dc_name
#   node  = consul_node.database.name
#   port  = 80
#   tags  = ["external"]
#   meta  = {}

#   check {
#     check_id = "service:consul"
#     name     = "Consul health check"
#     status   = "passing"
#     http     = var.consul_dc_addr
#     interval = "30s"
#     timeout  = "3s"
#   }
# }

# resource "consul_node" "dc" {
#   count   = var.consul_dc_addr != "" ? 1 : 0
#   name    = local.consul_dc_name
#   address = var.consul_dc_addr

#   meta = {
#     "external-node"  = "true"
#     "external-probe" = "true"
#   }
# }

# resource "consul_config_entry" "dc" {
#   count = var.consul_dc_addr != "" ? 1 : 0
#   name  = local.consul_dc_name
#   kind  = "service-defaults"

#   config_json = jsonencode({
#     Protocol    = "tcp"
#     Expose      = {}
#     MeshGateway = {}
#     Namespace   = "default"
#   })
# }

# resource "consul_acl_policy" "dc" {
#   count       = var.consul_dc_addr != "" ? 1 : 0
#   name        = "${local.consul_dc_name}-write-policy"
#   datacenters = [data.hcp_consul_cluster.cluster.datacenter]

#   rules = <<-RULE
#     service "${local.consul_dc_name}" {
#         policy = "write"
#     }
#     RULE
# }
