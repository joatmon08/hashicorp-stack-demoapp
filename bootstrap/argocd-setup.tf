resource "tfe_workspace" "argocd" {
  name              = "argocd-setup"
  organization      = tfe_organization.demo.name
  project_id        = tfe_project.platform.id
  description       = "Set up ArgoCD on Kubernetes"
  terraform_version = var.terraform_version
  working_directory = "argocd/setup"
  trigger_patterns  = ["argocd/setup/**/*"]
  queue_all_runs    = false
  vcs_repo {
    identifier                 = var.github_repository
    branch                     = var.github_branch
    github_app_installation_id = data.tfe_github_app_installation.gha_installation.id
  }
}

# resource "tfe_workspace_variable_set" "argocd_aws" {
#   workspace_id    = tfe_workspace.argocd.id
#   variable_set_id = tfe_variable_set.aws.id
# }

resource "tfe_workspace_variable_set" "argocd_common" {
  workspace_id    = tfe_workspace.argocd.id
  variable_set_id = tfe_variable_set.common.id
}