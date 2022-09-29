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

locals {
  region           = var.region == "" ? data.terraform_remote_state.infrastructure.outputs.region : var.region
  eks_cluster_name = var.aws_eks_cluster_id == "" ? data.terraform_remote_state.infrastructure.outputs.eks_cluster_id : var.aws_eks_cluster_id

  kubernetes_host   = var.kubernetes_host == "" ? data.aws_eks_cluster.cluster.endpoint : var.kubernetes_host
  consul_address    = var.consul_address == "" ? data.terraform_remote_state.infrastructure.outputs.hcp_consul_private_address : var.consul_address
  consul_datacenter = var.consul_datacenter == "" ? data.terraform_remote_state.infrastructure.outputs.hcp_consul_datacenter : var.consul_datacenter
}

variable "consul_address" {
  type        = string
  description = "Consul private address for CTS to connect"
  default     = ""
}

variable "consul_datacenter" {
  type        = string
  description = "Consul datacenter for CTS to connect"
  default     = ""
}

variable "kubernetes_host" {
  type        = string
  description = "Kubernetes host"
  default     = ""
}

variable "kubernetes_namespace" {
  type        = string
  description = "Namespace to deploy CTS"
  default     = "default"
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