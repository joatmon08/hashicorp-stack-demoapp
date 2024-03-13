resource "tfe_workspace" "consul_setup" {
  name              = "consul-setup"
  organization      = tfe_organization.demo.name
  project_id        = tfe_project.platform.id
  description       = "Set up Consul on Kubernetes"
  terraform_version = var.terraform_version
  working_directory = "consul/setup"
  trigger_prefixes  = ["consul/setup"]
  queue_all_runs    = false
  # remote_state_consumer_ids = [tfe_workspace.consul_config.id]
  vcs_repo {
    identifier                 = var.github_repository
    branch                     = var.github_branch
    github_app_installation_id = data.tfe_github_app_installation.gha_installation.id
  }
}

resource "tfe_workspace_variable_set" "consul_setup_hcp" {
  workspace_id    = tfe_workspace.consul_setup.id
  variable_set_id = tfe_variable_set.hcp.id
}

# resource "tfe_workspace_variable_set" "consul_setup_aws" {
#   workspace_id    = tfe_workspace.consul_setup.id
#   variable_set_id = tfe_variable_set.aws.id
# }

resource "tfe_workspace_variable_set" "consul_setup_common" {
  workspace_id    = tfe_workspace.consul_setup.id
  variable_set_id = tfe_variable_set.common.id
}

resource "tfe_variable" "consul_setup_observability" {
  workspace_id = tfe_workspace.consul_setup.id
  key          = "hcp_consul_observability_credentials"
  value = jsonencode({
    client_id     = var.hcp_consul_observability_credentials.client_id
    client_secret = var.hcp_consul_observability_credentials.client_secret
    resource_id   = var.hcp_consul_observability_credentials.resource_id
  })
  category  = "terraform"
  hcl       = true
  sensitive = true
}