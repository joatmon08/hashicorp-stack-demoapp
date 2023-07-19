resource "tfe_workspace" "datadog" {
  count                     = var.datadog_api_key != null ? 1 : 0
  name                      = "datadog-setup"
  organization              = tfe_organization.demo.name
  terraform_version         = var.terraform_version
  trigger_prefixes          = ["datadog/setup"]
  working_directory         = "datadog/setup"
  queue_all_runs            = false
  remote_state_consumer_ids = []

  vcs_repo {
    identifier     = var.github_repository
    branch         = var.github_branch
    oauth_token_id = tfe_oauth_client.github.oauth_token_id
  }
}

resource "tfe_workspace_variable_set" "datadog_datadog" {
  count           = var.datadog_api_key != null ? 1 : 0
  workspace_id    = tfe_workspace.datadog.0.id
  variable_set_id = tfe_variable_set.datadog.0.id
}

resource "tfe_workspace_variable_set" "infrastructure_datadog" {
  count           = var.datadog_api_key != null ? 1 : 0
  workspace_id    = tfe_workspace.infrastructure.id
  variable_set_id = tfe_variable_set.datadog.0.id
}