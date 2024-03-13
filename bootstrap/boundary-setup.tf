resource "tfe_workspace" "boundary_setup" {
  name                          = "boundary-setup"
  organization                  = tfe_organization.demo.name
  project_id                    = tfe_project.platform.id
  description                   = "Set up Boundary scopes and groups"
  terraform_version             = var.terraform_version
  working_directory             = "boundary/setup"
  trigger_patterns              = ["boundary/setup/**/*"]
  queue_all_runs                = false
  remote_state_consumer_ids     = [tfe_workspace.applications.id]
  speculative_enabled           = false
  structured_run_output_enabled = false

  vcs_repo {
    identifier                 = var.github_repository
    branch                     = var.github_branch
    github_app_installation_id = data.tfe_github_app_installation.gha_installation.id
  }
}

resource "tfe_workspace_variable_set" "boundary_setup_common" {
  workspace_id    = tfe_workspace.boundary_setup.id
  variable_set_id = tfe_variable_set.common.id
}