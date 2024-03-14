resource "tfe_workspace" "argocd_config" {
  name              = "argocd-config"
  organization      = tfe_organization.demo.name
  project_id        = tfe_project.platform.id
  description       = "Configure Argo CD projects"
  terraform_version = var.terraform_version
  working_directory = "argocd/config"
  trigger_patterns  = ["argocd/config/**/*"]
  queue_all_runs    = false
  vcs_repo {
    identifier                 = var.github_repository
    branch                     = var.github_branch
    github_app_installation_id = data.tfe_github_app_installation.gha_installation.id
  }
}

# resource "tfe_workspace_variable_set" "argocd_config_aws" {
#   workspace_id    = tfe_workspace.argocd_config.id
#   variable_set_id = tfe_variable_set.aws.id
# }

resource "tfe_workspace_variable_set" "argocd_config_common" {
  workspace_id    = tfe_workspace.argocd_config.id
  variable_set_id = tfe_variable_set.common.id
}