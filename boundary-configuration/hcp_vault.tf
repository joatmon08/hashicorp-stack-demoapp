resource "boundary_host_catalog" "vault" {
  name        = "hcp_vault"
  description = "HCP Vault Endpoint"
  type        = "static"
  scope_id    = boundary_scope.core_infra.id
}

resource "boundary_host" "vault" {
  type            = "static"
  name            = "hcp_vault"
  description     = "HCP Vault Endpoint"
  address         = local.vault_private_address
  host_catalog_id = boundary_host_catalog.vault.id
}

resource "boundary_host_set" "vault" {
  type            = "static"
  name            = "hcp_vault"
  description     = "Host set for HCP Vault"
  host_catalog_id = boundary_host_catalog.vault.id
  host_ids        = [boundary_host.vault.id]
}

resource "boundary_target" "vault" {
  type                     = "tcp"
  name                     = "hcp_vault"
  description              = "HCP Vault Target"
  scope_id                 = boundary_scope.core_infra.id
  session_connection_limit = -1
  default_port             = 8200
  host_source_ids = [
    boundary_host_set.vault.id
  ]
}