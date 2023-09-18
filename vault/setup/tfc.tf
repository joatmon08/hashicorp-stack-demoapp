resource "vault_terraform_cloud_secret_backend" "apps" {
  backend     = "terraform"
  description = "Manages the Terraform Cloud backend"
  token       = var.tfc_organization_token
}

resource "vault_terraform_cloud_secret_role" "apps" {
  for_each     = var.tfc_team_ids
  backend      = vault_terraform_cloud_secret_backend.apps.backend
  name         = each.key
  organization = var.tfc_organization
  team_id      = each.value
}