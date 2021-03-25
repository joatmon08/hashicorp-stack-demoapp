resource "boundary_host_catalog" "vault" {
  count       = var.vault_private_address != "" ? 1 : 0
  name        = "hcp_vault"
  description = "HCP Vault Endpoint"
  type        = "static"
  scope_id    = boundary_scope.core_infra.id
}

resource "boundary_host" "vault" {
  count           = var.vault_private_address != "" ? 1 : 0
  type            = "static"
  name            = "hcp_vault"
  description     = "HCP Vault Endpoint"
  address         = var.vault_private_address
  host_catalog_id = boundary_host_catalog.vault.0.id
}

resource "boundary_host_set" "vault" {
  count           = var.vault_private_address != "" ? 1 : 0
  type            = "static"
  name            = "hcp_vault"
  description     = "Host set for HCP Vault"
  host_catalog_id = boundary_host_catalog.vault.0.id
  host_ids        = [boundary_host.vault.0.id]
}

resource "boundary_target" "vault" {
  count                    = var.vault_private_address != "" ? 1 : 0
  type                     = "tcp"
  name                     = "hcp_vault"
  description              = "HCP Vault Target"
  scope_id                 = boundary_scope.core_infra.id
  session_connection_limit = -1
  default_port             = 8200
  host_set_ids = [
    boundary_host_set.vault.0.id
  ]
}