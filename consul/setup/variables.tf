variable "tfc_organization" {
  type        = string
  description = "TFC Organization for remote state of infrastructure"
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

data "terraform_remote_state" "vault_consul" {
  backend = "remote"

  config = {
    organization = var.tfc_organization
    workspaces = {
      name = "vault-consul"
    }
  }
}

locals {
  roles             = data.terraform_remote_state.vault_consul.outputs.roles
  paths             = data.terraform_remote_state.vault_consul.outputs.paths
  consul_datacenter = data.terraform_remote_state.vault_consul.outputs.consul_datacenter

  vault_public_addr     = data.terraform_remote_state.infrastructure.outputs.hcp_vault_public_address
  vault_addr            = data.terraform_remote_state.infrastructure.outputs.hcp_vault_private_address
  vault_namespace       = data.terraform_remote_state.infrastructure.outputs.hcp_vault_namespace
  vault_token           = data.terraform_remote_state.infrastructure.outputs.hcp_vault_token
  hcp_consul_cluster_id = data.terraform_remote_state.infrastructure.outputs.hcp_consul_cluster
}

variable "consul_helm_version" {
  type        = string
  description = "Consul Helm chart version"
  default     = "1.2.2"
}

variable "aws_eks_cluster_id" {
  type        = string
  description = "AWS EKS Cluster ID"
  default     = ""
}

variable "region" {
  type        = string
  description = "AWS Region"
  default     = ""
}

variable "namespace" {
  type        = string
  description = "Kubernetes namespace to deploy Consul"
  default     = "consul"
}

variable "hcp_consul_observability_credentials" {
  type = object({
    client_id     = string
    client_secret = string
    resource_id   = string
  })
  sensitive   = true
  description = "Credentials to enable mesh telemetry for HCP Consul Observability"
}