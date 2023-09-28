resource "tfe_registry_module" "terraform_aws_postgres" {
  organization = tfe_organization.demo.name
  vcs_repo {
    display_identifier = var.terraform_aws_postgres_module_identifier
    identifier         = var.terraform_aws_postgres_module_identifier
    oauth_token_id     = tfe_oauth_client.github.oauth_token_id
  }
}

resource "tfe_no_code_module" "terraform_aws_postgres" {
  organization    = tfe_organization.demo.name
  registry_module = tfe_registry_module.terraform_aws_postgres.id
}