variable "tfc_organization" {
  type        = string
  description = "TFC Organization for remote state of infrastructure"
}

variable "tfc_workspace" {
  type        = string
  description = "TFC Organization for remote state of infrastructure"
}

data "terraform_remote_state" "infrastructure" {
  backend = "remote"

  config = {
    organization = var.tfc_organization
    workspaces = {
      name = var.tfc_workspace
    }
  }
}

locals {
  products_database     = var.products_database_address == "" ? data.terraform_remote_state.infrastructure.outputs.product_database_address : var.products_database_address
  hcp_consul_cluster_id = var.hcp_consul_cluster_id == "" ? data.terraform_remote_state.infrastructure.outputs.hcp_consul_cluster : var.hcp_consul_cluster_id
}

variable "hcp_consul_cluster_id" {
  type        = string
  description = "HCP Consul Cluster ID for configuration"
  default     = ""
}

variable "aws_eks_cluster_id" {
  type        = string
  description = "AWS EKS Cluster ID"
  default     = ""
}

variable "products_database_address" {
  type        = string
  description = "Products database address"
  default     = ""
}

variable "consul_helm_version" {
  type        = string
  description = "Consul Helm chart version"
  default     = "0.33.0"
}

variable "region" {
  type        = string
  description = "AWS Region"
  default     = ""
}