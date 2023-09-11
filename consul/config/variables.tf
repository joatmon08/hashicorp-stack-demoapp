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

data "terraform_remote_state" "consul" {
  backend = "remote"

  config = {
    organization = var.tfc_organization
    workspaces = {
      name = "consul-setup"
    }
  }
}


data "terraform_remote_state" "vault" {
  backend = "remote"

  config = {
    organization = var.tfc_organization
    workspaces = {
      name = "vault-consul"
    }
  }
}

locals {
  consul_addr                = data.terraform_remote_state.consul.outputs.consul_address
  consul_token               = data.terraform_remote_state.consul.outputs.consul_token
  consul_scheme              = "https"
  vault_public_addr          = data.terraform_remote_state.infrastructure.outputs.hcp_vault_public_address
  vault_addr                 = var.vault_address == "" ? data.terraform_remote_state.infrastructure.outputs.hcp_vault_private_address : var.vault_address
  vault_token                = var.vault_token == "" ? data.terraform_remote_state.infrastructure.outputs.hcp_vault_token : var.vault_token
  vault_namespace            = var.vault_namespace == "" ? data.terraform_remote_state.infrastructure.outputs.hcp_vault_namespace : var.vault_namespace
  certificate_allowed_domain = var.certificate_allowed_domain == "" ? data.terraform_remote_state.vault.outputs.consul_api_gateway_allowed_domain : var.certificate_allowed_domain
}

variable "vault_address" {
  type        = string
  description = "Vault address"
  default     = ""
}

variable "vault_token" {
  type        = string
  description = "Vault token"
  default     = ""
  sensitive   = true
}

variable "vault_namespace" {
  type        = string
  description = "Vault namespace"
  default     = null
}

variable "products_database" {
  type        = string
  description = "Products database address"
  default     = ""
}

variable "certificate_allowed_domain" {
  type        = string
  description = "Allowed domain for Consul API Gateway certificate"
  default     = ""
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
  description = "Kubernetes namespace for Consul"
  default     = "consul"
}