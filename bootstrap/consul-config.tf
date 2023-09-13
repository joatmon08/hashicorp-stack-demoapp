# resource "tfe_workspace" "consul_config" {
#   name                      = "consul-config"
#   organization              = tfe_organization.demo.name
#   description               = "Step 8 - Configure Consul external services & API gateway"
#   terraform_version         = var.terraform_version
#   working_directory         = "consul/config"
#   trigger_prefixes          = ["consul/config"]
#   queue_all_runs            = false
#   remote_state_consumer_ids = []
#   vcs_repo {
#     identifier     = var.github_repository
#     branch         = var.github_branch
#     oauth_token_id = tfe_oauth_client.github.oauth_token_id
#   }
# }

# resource "tfe_workspace_variable_set" "consul_config_aws" {
#   workspace_id    = tfe_workspace.consul_config.id
#   variable_set_id = tfe_variable_set.aws.id
# }

# resource "tfe_workspace_variable_set" "consul_config_common" {
#   workspace_id    = tfe_workspace.consul_config.id
#   variable_set_id = tfe_variable_set.common.id
# }