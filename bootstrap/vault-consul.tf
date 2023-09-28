resource "tfe_workspace" "vault_consul" {
  name              = "vault-consul"
  organization      = tfe_organization.demo.name
  project_id        = tfe_project.platform.id
  description       = "Step 5 - Configure Vault for Consul (PKI Secrets Engine)"
  terraform_version = var.terraform_version
  working_directory = "vault/consul"
  trigger_prefixes  = ["vault/consul"]
  queue_all_runs    = false
  # remote_state_consumer_ids = [tfe_workspace.consul_setup.id, tfe_workspace.consul_config.id]
  remote_state_consumer_ids = [tfe_workspace.consul_setup.id]
  vcs_repo {
    identifier     = var.github_repository
    branch         = var.github_branch
    oauth_token_id = tfe_oauth_client.github.oauth_token_id
  }
}

resource "tfe_workspace_variable_set" "vault_consul_hcp" {
  workspace_id    = tfe_workspace.vault_consul.id
  variable_set_id = tfe_variable_set.hcp.id
}

resource "tfe_workspace_variable_set" "vault_consul_common" {
  workspace_id    = tfe_workspace.vault_consul.id
  variable_set_id = tfe_variable_set.common.id
}

resource "tfe_variable" "tfc_organization_token" {
  workspace_id = tfe_workspace.vault_applications.id
  key          = "tfc_organization_token"
  value        = tfe_organization_token.demo.token
  category     = "terraform"
  hcl          = false
  sensitive    = true
}

resource "tfe_variable" "vault_tfc_secrets_engine_team_ids" {
  key          = "tfc_team_ids"
  value        = jsonencode({ for team in tfe_team.business_units : team.name => team.id })
  category     = "terraform"
  hcl          = true
  description  = "Terraform Cloud team IDs to add to Vault secrets engine"
  workspace_id = tfe_workspace.vault_applications.id
  sensitive    = false
}
