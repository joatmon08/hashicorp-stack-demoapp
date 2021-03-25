resource "boundary_host_catalog" "consul" {
  count       = var.consul_private_address != "" ? 1 : 0
  name        = "hcp_consul"
  description = "HCP Consul Endpoint"
  type        = "static"
  scope_id    = boundary_scope.core_infra.id
}

resource "boundary_host" "consul" {
  count           = var.consul_private_address != "" ? 1 : 0
  type            = "static"
  name            = "hcp_consul"
  description     = "HCP Consul Endpoint"
  address         = var.consul_private_address
  host_catalog_id = boundary_host_catalog.consul.0.id
}

resource "boundary_host_set" "consul" {
  count           = var.consul_private_address != "" ? 1 : 0
  type            = "static"
  name            = "hcp_consul"
  description     = "Host set for HCP Consul"
  host_catalog_id = boundary_host_catalog.consul.0.id
  host_ids        = [boundary_host.consul.0.id]
}

resource "boundary_target" "consul" {
  count                    = var.consul_private_address != "" ? 1 : 0
  type                     = "tcp"
  name                     = "hcp_consul"
  description              = "HCP Consul Target"
  scope_id                 = boundary_scope.core_infra.id
  session_connection_limit = -1
  default_port             = 80
  host_set_ids = [
    boundary_host_set.consul.0.id
  ]
}