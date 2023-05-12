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

variable "hcp_client_id" {
  type        = string
  description = "HashiCorp Cloud Platform client ID. Create using https://developer.hashicorp.com/hcp/docs/hcp/security/service-principals"
}

variable "hcp_client_secret" {
  type        = string
  description = "HashiCorp Cloud Platform client secret. Create using https://developer.hashicorp.com/hcp/docs/hcp/security/service-principals"
  sensitive   = true
}

variable "aws_access_key_id" {
  type        = string
  description = "AWS access key ID"
}

variable "aws_secret_access_key" {
  type        = string
  description = "AWS secret access key"
  sensitive   = true
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

variable "consul_gossip_key" {
  type        = string
  description = "Consul gossip encryption key. Generate with `consul keygen`"
  sensitive   = true
}