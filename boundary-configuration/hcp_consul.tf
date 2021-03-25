resource "boundary_host_catalog" "consul" {
  name        = "hcp_consul"
  description = "HCP Consul Endpoint"
  type        = "static"
  scope_id    = boundary_scope.core_infra.id
}

resource "boundary_host" "consul" {
  type            = "static"
  name            = "hcp_consul"
  description     = "HCP Consul Endpoint"
  address         = local.consul_private_address
  host_catalog_id = boundary_host_catalog.consul.id
}

resource "boundary_host_set" "consul" {
  type            = "static"
  name            = "hcp_consul"
  description     = "Host set for HCP Consul"
  host_catalog_id = boundary_host_catalog.consul.id
  host_ids        = [boundary_host.consul.id]
}

resource "boundary_target" "consul" {
  type                     = "tcp"
  name                     = "hcp_consul"
  description              = "HCP Consul Target"
  scope_id                 = boundary_scope.core_infra.id
  session_connection_limit = -1
  default_port             = 443
  host_set_ids = [
    boundary_host_set.consul.id
  ]
}