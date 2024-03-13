resource "tfe_workspace" "infrastructure" {
  name                = "infrastructure"
  assessments_enabled = true
  organization        = tfe_organization.demo.name
  project_id          = tfe_project.platform.id
  description         = "Create infrastructure resources"
  terraform_version   = var.terraform_version
  working_directory   = "infrastructure"
  trigger_patterns    = ["infrastructure/*.tf"]
  queue_all_runs      = false
  global_remote_state = true
  auto_apply          = true
  vcs_repo {
    identifier                 = var.github_repository
    branch                     = var.github_branch
    github_app_installation_id = data.tfe_github_app_installation.gha_installation.id
  }
}

resource "tfe_workspace_variable_set" "infrastructure_common" {
  workspace_id    = tfe_workspace.infrastructure.id
  variable_set_id = tfe_variable_set.common.id
}

resource "tfe_workspace_variable_set" "infrastructure_hcp" {
  workspace_id    = tfe_workspace.infrastructure.id
  variable_set_id = tfe_variable_set.hcp.id
}

resource "tfe_variable" "region" {
  key          = "region"
  value        = var.region
  category     = "terraform"
  workspace_id = tfe_workspace.infrastructure.id
  description  = "AWS region"
}
