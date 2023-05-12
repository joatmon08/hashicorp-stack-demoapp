resource "tfe_workspace" "infrastructure" {
  name                = "infrastructure"
  organization        = tfe_organization.demo.name
  description         = "Step 1 - Create infrastructure resources"
  working_directory   = "infrastructure"
  trigger_prefixes    = ["infrastructure"]
  queue_all_runs      = false
  global_remote_state = true
  vcs_repo {
    identifier     = var.github_repository
    branch         = var.github_branch
    oauth_token_id = tfe_oauth_client.github.oauth_token_id
  }
}

resource "tfe_workspace_variable_set" "infrastructure_hcp" {
  workspace_id    = tfe_workspace.infrastructure.id
  variable_set_id = tfe_variable_set.hcp.id
}

resource "tfe_workspace_variable_set" "infrastructure_aws" {
  workspace_id    = tfe_workspace.infrastructure.id
  variable_set_id = tfe_variable_set.aws.id
}

resource "tfe_variable" "allow_cidr_blocks" {
  key          = "client_cidr_block"
  value        = jsonencode(var.allow_cidr_blocks)
  hcl          = true
  category     = "terraform"
  workspace_id = tfe_workspace.infrastructure.id
  description  = "Allow access to infrastructure resources from external CIDR blocks"
  sensitive    = true
}