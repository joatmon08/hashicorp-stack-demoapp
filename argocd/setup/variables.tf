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

variable "argocd_helm_version" {
  type        = string
  description = "ArgoCD Helm version"
  default     = "6.7.1"
}

variable "terraform_cloud_operator_version" {
  type        = string
  description = "Terraform Cloud Operator Helm chart version"
  default     = "2.2.0"
}

variable "hcp_organization_id" {
  type        = string
  description = "HashiCorp Cloud Platform organization ID."
}

variable "hcp_project_id" {
  type        = string
  description = "HashiCorp Cloud Platform project ID."
}