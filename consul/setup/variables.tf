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
  vault_addr        = data.terraform_remote_state.vault_consul.outputs.vault_addr
  vault_namespace   = data.terraform_remote_state.vault_consul.outputs.vault_namespace
}

variable "consul_helm_version" {
  type        = string
  description = "Consul Helm chart version"
  default     = "0.44.0"
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