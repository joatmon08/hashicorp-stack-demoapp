resource "tfe_workspace" "waypoint" {
  name              = "waypoint"
  organization      = tfe_organization.demo.name
  project_id        = tfe_project.platform.id
  description       = "Set up Waypoint templates"
  terraform_version = var.terraform_version
  working_directory = "waypoint"
  trigger_patterns  = ["waypoint/**/*"]
  queue_all_runs    = false
  vcs_repo {
    identifier                 = var.github_repository
    branch                     = var.github_branch
    github_app_installation_id = data.tfe_github_app_installation.gha_installation.id
  }
}

resource "tfe_workspace_variable_set" "waypoint_hcp" {
  workspace_id    = tfe_workspace.waypoint.id
  variable_set_id = tfe_variable_set.hcp.id
}