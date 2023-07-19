resource "tfe_workspace" "vault_setup" {
  name                      = "vault-setup"
  organization              = tfe_organization.demo.name
  description               = "Step 3 - Set up Vault on Kubernetes"
  terraform_version         = var.terraform_version
  working_directory         = "vault/setup"
  trigger_prefixes          = ["vault/setup"]
  queue_all_runs            = false
  remote_state_consumer_ids = [tfe_workspace.boundary.id, tfe_workspace.vault_consul.id]
  vcs_repo {
    identifier     = var.github_repository
    branch         = var.github_branch
    oauth_token_id = tfe_oauth_client.github.oauth_token_id
  }
}

resource "tfe_workspace_variable_set" "vault_setup_aws" {
  workspace_id    = tfe_workspace.vault_setup.id
  variable_set_id = tfe_variable_set.aws.id
}

resource "tfe_workspace_variable_set" "vault_setup_hcp" {
  workspace_id    = tfe_workspace.vault_setup.id
  variable_set_id = tfe_variable_set.hcp.id
}

resource "tfe_workspace_variable_set" "vault_setup_common" {
  workspace_id    = tfe_workspace.vault_setup.id
  variable_set_id = tfe_variable_set.common.id
}