resource "tfe_workspace" "consul_cts" {
  name                      = "consul-cts"
  organization              = tfe_organization.demo.name
  terraform_version         = var.terraform_version
  trigger_prefixes          = ["consul/cts"]
  working_directory         = "consul/cts"
  queue_all_runs            = false
  remote_state_consumer_ids = []

  vcs_repo {
    identifier     = var.github_repository
    branch         = var.github_branch
    oauth_token_id = tfe_oauth_client.github.oauth_token_id
  }
}