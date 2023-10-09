resource "tfe_workspace" "vault_applications" {
  name              = "vault-applications"
  organization      = tfe_organization.demo.name
  project_id        = tfe_project.platform.id
  description       = "Step 5 - Configure Vault for Applications"
  terraform_version = var.terraform_version
  working_directory = "vault/applications"
  trigger_prefixes  = ["vault/applications"]
  queue_all_runs    = false
  vcs_repo {
    identifier     = var.github_repository
    branch         = var.github_branch
    oauth_token_id = tfe_oauth_client.github.oauth_token_id
  }
}

resource "tfe_workspace_variable_set" "vault_applications_common" {
  workspace_id    = tfe_workspace.vault_applications.id
  variable_set_id = tfe_variable_set.common.id
}

resource "tfe_variable" "github_user" {
  key          = "github_user"
  value        = var.github_user
  category     = "terraform"
  workspace_id = tfe_workspace.vault_applications.id
  description  = "GitHub user for Vault auth method"
}

locals {
  team_ids = merge({
    for key, value in tfe_team.business_units : key => tfe_team.business_units[key].id
    }, {
    "${tfe_team.backstage.name}" = tfe_team.backstage.id
  })
}

resource "tfe_variable" "tfc_organization_token" {
  workspace_id = tfe_workspace.vault_applications.id
  key          = "tfc_organization_token"
  value        = tfe_organization_token.demo.token
  category     = "terraform"
  hcl          = false
  sensitive    = true
}

resource "tfe_variable" "team_ids" {
  key          = "tfc_team_ids"
  value        = jsonencode(local.team_ids)
  category     = "terraform"
  hcl          = true
  workspace_id = tfe_workspace.vault_applications.id
  description  = "Terraform Cloud team IDs to add to Vault secrets engine"
}
