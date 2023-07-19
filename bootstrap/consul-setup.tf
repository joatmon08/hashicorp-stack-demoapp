resource "tfe_workspace" "consul_setup" {
  name                      = "consul-setup"
  organization              = tfe_organization.demo.name
  description               = "Step 6 - Set up Consul on Kubernetes"
  terraform_version         = var.terraform_version
  working_directory         = "consul/setup"
  trigger_prefixes          = ["consul/setup"]
  queue_all_runs            = false
  remote_state_consumer_ids = [tfe_workspace.consul_config.id]
  vcs_repo {
    identifier     = var.github_repository
    branch         = var.github_branch
    oauth_token_id = tfe_oauth_client.github.oauth_token_id
  }
}

resource "tfe_workspace_variable_set" "consul_setup_hcp" {
  workspace_id    = tfe_workspace.consul_setup.id
  variable_set_id = tfe_variable_set.hcp.id
}

resource "tfe_workspace_variable_set" "consul_setup_aws" {
  workspace_id    = tfe_workspace.consul_setup.id
  variable_set_id = tfe_variable_set.aws.id
}

resource "tfe_workspace_variable_set" "consul_setup_common" {
  workspace_id    = tfe_workspace.consul_setup.id
  variable_set_id = tfe_variable_set.common.id
}