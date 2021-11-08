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
  kubernetes_host         = var.kubernetes_host == "" ? data.aws_eks_cluster.cluster.endpoint : var.kubernetes_host
  postgres_hostname       = var.postgres_hostname == "" ? data.terraform_remote_state.infrastructure.outputs.product_database_address : var.postgres_hostname
  postgres_username       = var.postgres_username == "" ? data.terraform_remote_state.infrastructure.outputs.product_database_username : var.postgres_username
  postgres_password       = var.postgres_password == "" ? data.terraform_remote_state.infrastructure.outputs.product_database_password : var.postgres_password
  hcp_vault_cluster_id    = var.hcp_vault_cluster_id == "" ? data.terraform_remote_state.infrastructure.outputs.hcp_vault_cluster : var.hcp_vault_cluster_id
  hcp_vault_cluster_token = var.hcp_vault_cluster_token == "" ? data.terraform_remote_state.infrastructure.outputs.hcp_vault_token : var.hcp_vault_cluster_token
}

data "hcp_vault_cluster" "cluster" {
  cluster_id = local.hcp_vault_cluster_id
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

variable "postgres_hostname" {
  type        = string
  default     = ""
  description = "PostgreSQL hostname"
  sensitive   = true
}

variable "postgres_port" {
  type        = number
  description = "PostgreSQL port"
  default     = 5432
}

variable "postgres_username" {
  type        = string
  description = "PostgreSQL username"
  sensitive   = true
  default     = ""
}

variable "postgres_password" {
  type        = string
  description = "PostgreSQL password"
  sensitive   = true
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
  default     = "0.17.1"
}