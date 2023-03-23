resource "tfe_workspace" "vault_consul" {
  name                      = "vault-consul"
  organization              = tfe_organization.demo.name
  description               = "Step 5 - Configure Vault for Consul (PKI Secrets Engine)"
  working_directory         = "vault/consul"
  trigger_prefixes          = ["vault/consul"]
  queue_all_runs            = false
  remote_state_consumer_ids = [tfe_workspace.consul_setup.id, tfe_workspace.consul_config.id]
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