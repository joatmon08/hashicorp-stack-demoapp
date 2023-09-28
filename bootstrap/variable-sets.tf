resource "tfe_variable_set" "hcp" {
  name         = "HashiCorp Cloud Platform"
  description  = "Service principal credentials for HashiCorp Cloud Platform"
  organization = tfe_organization.demo.name
  global       = false
}

resource "tfe_variable" "hcp_client_id" {
  key             = "HCP_CLIENT_ID"
  value           = var.hcp_client_id
  category        = "env"
  description     = "HCP Client ID"
  variable_set_id = tfe_variable_set.hcp.id
}

resource "tfe_variable" "hcp_client_secret" {
  key             = "HCP_CLIENT_SECRET"
  value           = var.hcp_client_secret
  category        = "env"
  description     = "HCP Client Secret"
  variable_set_id = tfe_variable_set.hcp.id
  sensitive       = true
}

resource "tfe_variable_set" "aws" {
  name         = "AWS"
  description  = "AWS credentials from HashiCorp Doormat"
  organization = tfe_organization.demo.name
  global       = true
}

resource "tfe_variable" "aws_access_key_id" {
  count           = var.aws_access_key_id == null ? 0 : 1
  key             = "AWS_ACCESS_KEY_ID"
  value           = var.aws_access_key_id
  category        = "env"
  description     = "AWS access key ID"
  variable_set_id = tfe_variable_set.aws.id
}

resource "tfe_variable" "aws_secret_access_key" {
  count           = var.aws_secret_access_key == null ? 0 : 1
  key             = "AWS_SECRET_ACCESS_KEY"
  value           = var.aws_secret_access_key
  category        = "env"
  description     = "AWS secret access key"
  variable_set_id = tfe_variable_set.aws.id
  sensitive       = true
}

resource "tfe_variable" "aws_session_token" {
  count           = var.aws_session_token == null ? 0 : 1
  key             = "AWS_SESSION_TOKEN"
  value           = var.aws_secret_access_key
  category        = "env"
  description     = "AWS session token"
  variable_set_id = tfe_variable_set.aws.id
  sensitive       = true
}

resource "tfe_variable" "aws_session_expiration" {
  count           = var.aws_session_expiration == null ? 0 : 1
  key             = "AWS_SESSION_EXPIRATION"
  value           = var.aws_session_expiration
  category        = "env"
  description     = "AWS session expiration"
  variable_set_id = tfe_variable_set.aws.id
}

resource "tfe_variable_set" "common" {
  name         = "Common"
  description  = "Common variables for use"
  organization = tfe_organization.demo.name
  global       = false
}

resource "tfe_variable" "tfc_organization" {
  key             = "tfc_organization"
  value           = tfe_organization.demo.name
  category        = "terraform"
  description     = "Terraform Cloud organization"
  variable_set_id = tfe_variable_set.common.id
}

resource "tfe_variable" "client_cidr_block" {
  key             = "client_cidr_block"
  value           = jsonencode(var.allow_cidr_blocks)
  category        = "terraform"
  hcl             = true
  description     = "Client CIDR blocks to allow traffic"
  variable_set_id = tfe_variable_set.common.id
}

resource "tfe_variable_set" "datadog" {
  count        = var.datadog_api_key != null ? 1 : 0
  name         = "Datadog"
  description  = "Datadog variables"
  organization = tfe_organization.demo.name
  global       = false
}

resource "tfe_variable" "datadog_api_key" {
  count           = var.datadog_api_key != null ? 1 : 0
  key             = "datadog_api_key"
  value           = var.datadog_api_key
  category        = "terraform"
  description     = "Datadog API Key"
  variable_set_id = tfe_variable_set.datadog.0.id
  sensitive       = true
}

resource "tfe_variable_set" "applications" {
  name         = "Applications"
  description  = "Variable set for application teams to use"
  organization = tfe_organization.demo.name
  global       = false
}

resource "tfe_project_variable_set" "applications" {
  for_each        = toset(var.business_units)
  variable_set_id = tfe_variable_set.applications.id
  project_id      = tfe_project.business_units[each.value].id
}

data "terraform_remote_state" "infrastructure" {
  backend = "remote"

  config = {
    organization = var.tfc_organization
    workspaces = {
      name = "infrastructure"
    }
  }
}


resource "tfe_variable" "vault_address" {
  count           = lookup(data.terraform_remote_state.infrastructure.outputs, "hcp_vault_public_address", null) == null ? 0 : 1
  key             = "VAULT_ADDR"
  value           = data.terraform_remote_state.infrastructure.outputs.hcp_vault_public_address
  category        = "env"
  description     = "HCP Vault address for configuration"
  variable_set_id = tfe_variable_set.applications.id
}

resource "tfe_variable" "vault_namespace" {
  count           = lookup(data.terraform_remote_state.infrastructure.outputs, "hcp_vault_namespace", null) == null ? 0 : 1
  key             = "VAULT_NAMESPACE"
  value           = data.terraform_remote_state.infrastructure.outputs.hcp_vault_namespace
  category        = "env"
  description     = "HCP Vault namespace for configuration"
  variable_set_id = tfe_variable_set.applications.id
}

resource "tfe_variable" "vault_token" {
  count           = lookup(data.terraform_remote_state.infrastructure.outputs, "hcp_vault_token", null) == null ? 0 : 1
  key             = "VAULT_TOKEN"
  value           = data.terraform_remote_state.infrastructure.outputs.hcp_vault_token
  category        = "env"
  description     = "HCP Vault token for configuration"
  variable_set_id = tfe_variable_set.applications.id
  sensitive       = true
}

resource "tfe_variable" "boundary_address" {
  count           = lookup(data.terraform_remote_state.infrastructure.outputs, "hcp_boundary_endpoint", null) == null ? 0 : 1
  key             = "boundary_address"
  value           = data.terraform_remote_state.infrastructure.outputs.hcp_boundary_endpoint
  category        = "terraform"
  hcl             = false
  description     = "HCP Boundary address for configuration"
  variable_set_id = tfe_variable_set.applications.id
}

resource "tfe_variable" "boundary_username" {
  count           = lookup(data.terraform_remote_state.infrastructure.outputs, "hcp_boundary_username", null) == null ? 0 : 1
  key             = "boundary_username"
  value           = data.terraform_remote_state.infrastructure.outputs.hcp_boundary_username
  category        = "terraform"
  hcl             = false
  description     = "HCP Boundary username for configuration"
  variable_set_id = tfe_variable_set.applications.id
}

resource "tfe_variable" "boundary_password" {
  count           = lookup(data.terraform_remote_state.infrastructure.outputs, "hcp_boundary_password", null) == null ? 0 : 1
  key             = "boundary_password"
  value           = data.terraform_remote_state.infrastructure.outputs.hcp_boundary_password
  category        = "terraform"
  hcl             = false
  description     = "HCP Boundary password for configuration"
  variable_set_id = tfe_variable_set.applications.id
  sensitive       = true
}

resource "tfe_variable" "consul_address" {
  count           = lookup(data.terraform_remote_state.infrastructure.outputs, "hcp_consul_public_address", null) == null ? 0 : 1
  key             = "consul_address"
  value           = data.terraform_remote_state.infrastructure.outputs.hcp_consul_public_address
  category        = "terraform"
  hcl             = false
  description     = "HCP Consul address for configuration"
  variable_set_id = tfe_variable_set.applications.id
}

resource "tfe_variable" "consul_datacenter" {
  count           = lookup(data.terraform_remote_state.infrastructure.outputs, "hcp_consul_datacenter", null) == null ? 0 : 1
  key             = "consul_datacenter"
  value           = data.terraform_remote_state.infrastructure.outputs.hcp_consul_datacenter
  category        = "terraform"
  hcl             = false
  description     = "HCP Consul datacenter for configuration"
  variable_set_id = tfe_variable_set.applications.id
}

resource "tfe_variable" "consul_token" {
  count           = lookup(data.terraform_remote_state.infrastructure.outputs, "hcp_consul_token", null) == null ? 0 : 1
  key             = "CONSUL_HTTP_TOKEN"
  value           = data.terraform_remote_state.infrastructure.outputs.hcp_consul_token
  category        = "env"
  hcl             = false
  description     = "HCP Consul token for configuration"
  variable_set_id = tfe_variable_set.applications.id
  sensitive       = true
}