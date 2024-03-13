resource "tfe_workspace" "vault_setup" {
  name                      = "vault-setup"
  organization              = tfe_organization.demo.name
  project_id                = tfe_project.platform.id
  description               = "Set up Vault on Kubernetes"
  terraform_version         = var.terraform_version
  working_directory         = "vault/setup"
  trigger_patterns          = ["vault/setup/**/*"]
  queue_all_runs            = false
  remote_state_consumer_ids = [tfe_workspace.boundary_setup.id, tfe_workspace.vault_consul.id, tfe_workspace.applications.id]
  vcs_repo {
    identifier                 = var.github_repository
    branch                     = var.github_branch
    github_app_installation_id = data.tfe_github_app_installation.gha_installation.id
  }
}

resource "tfe_workspace_variable_set" "vault_setup_hcp" {
  workspace_id    = tfe_workspace.vault_setup.id
  variable_set_id = tfe_variable_set.hcp.id
}

resource "tfe_workspace_variable_set" "vault_setup_common" {
  workspace_id    = tfe_workspace.vault_setup.id
  variable_set_id = tfe_variable_set.common.id
}

resource "tfe_variable" "github_organization" {
  key          = "github_organization"
  value        = var.github_organization
  category     = "terraform"
  workspace_id = tfe_workspace.vault_setup.id
  description  = "GitHub Organization for Vault auth method"
}

resource "tfe_variable" "github_organization_id" {
  key          = "github_organization_id"
  value        = var.github_organization_id
  category     = "terraform"
  workspace_id = tfe_workspace.vault_setup.id
  description  = "GitHub Organization ID for Vault auth method"
}