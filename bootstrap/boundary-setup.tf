resource "tfe_workspace" "boundary_setup" {
  name                          = "boundary-setup"
  organization                  = tfe_organization.demo.name
  project_id                    = tfe_project.platform.id
  description                   = "Set up Boundary scopes and groups"
  terraform_version             = var.terraform_version
  working_directory             = "boundary/setup"
  trigger_prefixes              = ["boundary/setup"]
  queue_all_runs                = false
  remote_state_consumer_ids     = [tfe_workspace.applications.id]
  speculative_enabled           = false
  structured_run_output_enabled = false

  vcs_repo {
    identifier     = var.github_repository
    branch         = var.github_branch
    oauth_token_id = tfe_oauth_client.github.oauth_token_id
  }
}

resource "tfe_workspace_variable_set" "boundary_setup_common" {
  workspace_id    = tfe_workspace.boundary_setup.id
  variable_set_id = tfe_variable_set.common.id
}