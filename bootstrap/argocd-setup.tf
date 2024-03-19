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

resource "tfe_workspace_variable_set" "argocd_hcp" {
  workspace_id    = tfe_workspace.argocd.id
  variable_set_id = tfe_variable_set.hcp.id
}

resource "tfe_workspace_variable_set" "argocd_common" {
  workspace_id    = tfe_workspace.argocd.id
  variable_set_id = tfe_variable_set.common.id
}

resource "tfe_variable" "hcp_project_id_tf" {
  key          = "hcp_project_id"
  value        = var.hcp_project_id
  category     = "terraform"
  description  = "HCP Project ID"
  workspace_id = tfe_workspace.argocd.id
  sensitive    = false
}

resource "tfe_variable" "hcp_organization_id_tf" {
  key          = "hcp_organization_id"
  value        = var.hcp_organization_id
  category     = "terraform"
  description  = "HCP Organization ID"
  workspace_id = tfe_workspace.argocd.id
  sensitive    = false
}
