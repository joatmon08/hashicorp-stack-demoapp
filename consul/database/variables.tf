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

locals {
  products_database = var.products_database == "" ? data.terraform_remote_state.infrastructure.outputs.product_database_address : var.products_database
}

variable "products_database" {
  type        = string
  description = "Products database address"
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