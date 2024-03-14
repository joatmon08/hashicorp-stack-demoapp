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

data "terraform_remote_state" "vault_setup" {
  backend = "remote"

  config = {
    organization = var.tfc_organization
    workspaces = {
      name = "vault-setup"
    }
  }
}

data "terraform_remote_state" "boundary_setup" {
  backend = "remote"

  config = {
    organization = var.tfc_organization
    workspaces = {
      name = "boundary-setup"
    }
  }
}

locals {
  boundary_address  = data.terraform_remote_state.infrastructure.outputs.hcp_boundary_endpoint
  boundary_username = data.terraform_remote_state.infrastructure.outputs.hcp_boundary_username
  boundary_password = data.terraform_remote_state.infrastructure.outputs.hcp_boundary_password

  consul_address    = data.terraform_remote_state.infrastructure.outputs.hcp_consul_public_address
  consul_token      = data.terraform_remote_state.infrastructure.outputs.hcp_consul_token
  consul_datacenter = data.terraform_remote_state.infrastructure.outputs.hcp_consul_datacenter

  vault_address   = data.terraform_remote_state.infrastructure.outputs.hcp_vault_public_address
  vault_token     = data.terraform_remote_state.infrastructure.outputs.hcp_vault_token
  vault_namespace = data.terraform_remote_state.infrastructure.outputs.hcp_vault_namespace

  vault_private_address = data.terraform_remote_state.infrastructure.outputs.hcp_vault_private_address

  vault_kubernetes_auth_path           = data.terraform_remote_state.vault_setup.outputs.vault_kubernetes_auth_path
  vault_kubernetes_secrets_engine_path = data.terraform_remote_state.vault_setup.outputs.vault_kubernetes_secrets_engine_path
  boundary_cluster_role                = data.terraform_remote_state.vault_setup.outputs.boundary_cluster_role

  vault_github_auth_path = data.terraform_remote_state.vault_setup.outputs.vault_github_auth_path

  boundary_org_id                  = data.terraform_remote_state.boundary_setup.outputs.boundary_org_id
  boundary_password_auth_method_id = data.terraform_remote_state.boundary_setup.outputs.boundary_password_auth_method_id

  name             = data.terraform_remote_state.infrastructure.outputs.hcp_boundary_cluster
  region           = data.terraform_remote_state.infrastructure.outputs.region
  eks_cluster_name = data.terraform_remote_state.infrastructure.outputs.eks_cluster_id
}

variable "tfc_organization_token" {
  type        = string
  description = "TFC Organization token for Vault secrets engine"
}

variable "tfc_team_ids" {
  type        = map(string)
  description = "TFC Team IDs to enable for Vault secrets engine"
}

variable "products_team" {
  type = set(string)
}

variable "change_to_rotate_password" {
  type        = bool
  description = "Update the reverse of this value to rotate payments-processor password"
  default     = false
}

variable "github_user" {
  type        = string
  description = "GitHub user for auth backend"
}

variable "mongodbatlas_public_key" {
  type        = string
  description = "MongoDB Atlas public key"
  default     = null
}

variable "mongodbatlas_private_key" {
  type        = string
  description = "MongoDB Atlas private key"
  default     = null
  sensitive   = true
}

variable "mongodbatlas_project_id" {
  type        = string
  description = "MongoDB Atlas project ID"
  default     = null
}

variable "mongodbatlas_region" {
  type        = string
  description = "MongoDB Atlas provider region"
  default     = null
}

variable "deployed_payments_processor" {
  type        = bool
  description = "Enable if payments processor is deployed to set up Boundary target"
  default     = false
}