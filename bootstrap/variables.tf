variable "terraform_version" {
  type        = string
  description = "Terraform version for all workspaces"
  default     = "1.5.7"
}

variable "tfc_organization" {
  type        = string
  description = "Terraform Cloud organization name"
  default     = "hashicorp-stack-demoapp"
}

variable "email" {
  type        = string
  description = "Email to link to Terraform Cloud organization name"
  sensitive   = true
}

variable "github_token" {
  type        = string
  description = "Github Token to pull repository. Create using https://developer.hashicorp.com/terraform/cloud-docs/api-docs/oauth-clients#create-an-oauth-client"
  sensitive   = true
}

variable "github_repository" {
  type        = string
  description = "Github Repository to reference in workspaces"
}

variable "github_branch" {
  type        = string
  description = "Github Repository branch to reference in workspaces"
  default     = "main"
}

variable "github_organization" {
  type        = string
  description = "GitHub organization for Vault auth method"
}

variable "github_organization_id" {
  type        = string
  description = "GitHub organization ID for Vault auth method"
}

variable "github_user" {
  type        = string
  description = "GitHub user for Vault auth method"
}

variable "hcp_client_id" {
  type        = string
  description = "HashiCorp Cloud Platform client ID. Create using https://developer.hashicorp.com/hcp/docs/hcp/security/service-principals"
}

variable "hcp_client_secret" {
  type        = string
  description = "HashiCorp Cloud Platform client secret. Create using https://developer.hashicorp.com/hcp/docs/hcp/security/service-principals"
  sensitive   = true
}

variable "hcp_project_id" {
  type        = string
  description = "HashiCorp Cloud Platform project ID."
}

variable "aws_access_key_id" {
  type        = string
  description = "AWS access key ID"
  default     = null
}

variable "aws_secret_access_key" {
  type        = string
  description = "AWS secret access key"
  sensitive   = true
  default     = null
}

variable "aws_session_token" {
  type        = string
  description = "AWS session token, if applicable"
  sensitive   = true
  default     = null
}

variable "aws_session_expiration" {
  type        = string
  description = "AWS session expiration, if applicable"
  default     = null
}

variable "allow_cidr_blocks" {
  type        = list(string)
  description = "Allow CIDR blocks to access infrastructure resources. Limit using `curl ifconfig.me`. Should be of format [\"x.x.x.x/x\"]"
  default     = ["0.0.0.0/0"]
}

variable "datadog_api_key" {
  type        = string
  description = "Datadog API key, if applicable"
  default     = null
}

variable "hcp_consul_observability_credentials" {
  type = object({
    client_id     = string
    client_secret = string
    resource_id   = string
  })
  sensitive   = true
  description = "Credentials to enable mesh telemetry for HCP Consul Observability"
  default = {
    client_id     = ""
    client_secret = ""
    resource_id   = ""
  }
}

variable "business_units" {
  type        = list(string)
  description = "Business units lined up with projects and teams"
  default = [
    "promotions",
    "hashicups",
    "expense-report",
    "payments-app"
  ]
}

variable "terraform_aws_postgres_module_identifier" {
  type        = string
  description = "GitHub identifier for terraform-aws-postgres module"
  default     = "joatmon08/terraform-aws-postgres"
}

variable "region" {
  type        = string
  description = "Region for AWS infrastructure and HCP"
  default     = "us-east-1"
}