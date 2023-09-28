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

  kubernetes_host           = var.kubernetes_host == "" ? data.aws_eks_cluster.cluster.endpoint : var.kubernetes_host
  hcp_vault_cluster_id      = var.hcp_vault_cluster_id == "" ? data.terraform_remote_state.infrastructure.outputs.hcp_vault_cluster : var.hcp_vault_cluster_id
  hcp_vault_public_address  = data.terraform_remote_state.infrastructure.outputs.hcp_vault_public_address
  hcp_vault_private_address = data.terraform_remote_state.infrastructure.outputs.hcp_vault_private_address
  hcp_vault_namespace       = data.terraform_remote_state.infrastructure.outputs.hcp_vault_namespace
  hcp_vault_cluster_token   = var.hcp_vault_cluster_token == "" ? data.terraform_remote_state.infrastructure.outputs.hcp_vault_token : var.hcp_vault_cluster_token
}

variable "hcp_vault_cluster_id" {
  type        = string
  description = "HCP Vault Cluster ID for configuration"
  default     = ""
}

variable "hcp_vault_cluster_token" {
  type        = string
  description = "HCP Vault Cluster token for configuration"
  default     = ""
  sensitive   = true
}

variable "kubernetes_host" {
  type        = string
  description = "Kubernetes host"
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

variable "vault_helm_version" {
  type        = string
  description = "Vault Helm chart version"
  default     = "0.25.0"
}

variable "csi_helm_version" {
  type        = string
  description = "Secrets Store CSI Driver Helm chart version"
  default     = "1.3.4"
}

variable "vault_operator_helm_version" {
  type        = string
  description = "Secrets Store CSI Driver Helm chart version"
  default     = "0.3.1"
}