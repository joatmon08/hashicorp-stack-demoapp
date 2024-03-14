resource "tfe_workspace" "applications" {
  name              = "applications"
  organization      = tfe_organization.demo.name
  project_id        = tfe_project.platform.id
  description       = "Configure Platform Components for Applications"
  terraform_version = var.terraform_version
  working_directory = "application/terraform"
  trigger_patterns  = ["application/terraform/**/*"]
  queue_all_runs    = false
  auto_apply        = true
  vcs_repo {
    identifier                 = var.github_repository
    branch                     = var.github_branch
    github_app_installation_id = data.tfe_github_app_installation.gha_installation.id
  }
}

resource "tfe_workspace_variable_set" "applications_common" {
  workspace_id    = tfe_workspace.applications.id
  variable_set_id = tfe_variable_set.common.id
}

resource "tfe_variable" "github_user" {
  key          = "github_user"
  value        = var.github_user
  category     = "terraform"
  workspace_id = tfe_workspace.applications.id
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
  workspace_id = tfe_workspace.applications.id
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
  workspace_id = tfe_workspace.applications.id
  description  = "Terraform Cloud team IDs to add to Vault secrets engine"
}

resource "tfe_workspace_variable_set" "mongodb" {
  count           = var.mongodb_atlas != null ? 1 : 0
  workspace_id    = tfe_workspace.applications.id
  variable_set_id = tfe_variable_set.mongodb.0.id
}