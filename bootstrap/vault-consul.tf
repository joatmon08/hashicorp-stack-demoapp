resource "tfe_workspace" "vault_consul" {
  name              = "vault-consul"
  organization      = tfe_organization.demo.name
  project_id        = tfe_project.platform.id
  description       = "Configure Vault for Consul (PKI Secrets Engine)"
  terraform_version = var.terraform_version
  working_directory = "vault/consul"
  trigger_prefixes  = ["vault/consul"]
  queue_all_runs    = false
  # remote_state_consumer_ids = [tfe_workspace.consul_setup.id, tfe_workspace.consul_config.id]
  remote_state_consumer_ids = [tfe_workspace.consul_setup.id]
  vcs_repo {
    identifier                 = var.github_repository
    branch                     = var.github_branch
    github_app_installation_id = data.tfe_github_app_installation.gha_installation.id
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