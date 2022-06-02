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
  products_database          = var.products_database == "" ? data.terraform_remote_state.infrastructure.outputs.product_database_address : var.products_database
  vault_addr                 = var.vault_address == "" ? data.terraform_remote_state.infrastructure.outputs.hcp_vault_private_address : var.vault_address
  certificate_allowed_domain = var.certificate_allowed_domain == "" ? data.terraform_remote_state.vault.outputs.consul_api_gateway_allowed_domain : var.certificate_allowed_domain
}

variable "vault_address" {
  type        = string
  description = "Vault address"
  default     = ""
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
  default     = "default"
}