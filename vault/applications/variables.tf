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

  vault_kubernetes_auth_path = data.terraform_remote_state.vault_setup.outputs.vault_kubernetes_auth_path
}