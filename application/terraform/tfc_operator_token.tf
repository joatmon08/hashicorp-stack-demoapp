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

resource "vault_policy" "tfc_secrets_engine" {
  for_each = toset(keys(var.tfc_team_ids))
  name     = "tfc-secrets-engine-${each.value}"

  policy = <<EOT
path "${vault_terraform_cloud_secret_backend.apps.backend}/creds/${each.value}" {
  capabilities = [ "read" ]
}
EOT
}

resource "vault_policy" "tfc_module_variables" {
  for_each = toset(keys(var.tfc_team_ids))
  name     = "tfc-module-variables-${each.value}"

  policy = <<EOT
path "${vault_mount.tfc_operator_vars[each.value].path}/*" {
  capabilities = [ "read" ]
}
EOT
}

resource "vault_kubernetes_auth_backend_role" "tfc_token" {
  for_each                         = toset(keys(var.tfc_team_ids))
  backend                          = local.vault_kubernetes_auth_path
  role_name                        = each.value
  bound_service_account_names      = ["terraform-cloud"]
  bound_service_account_namespaces = [each.value]
  token_ttl                        = 86400
  token_policies = [
    vault_policy.tfc_secrets_engine[each.value].name,
    vault_policy.tfc_module_variables[each.value].name,
    vault_policy.mongodbatlas_creds[each.value].name,
  ]
}