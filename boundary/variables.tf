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

variable "client_cidr_block" {
  type        = list(string)
  description = "Client CIDR block"
  sensitive   = true
}

variable "operations_team" {
  type = set(string)
}

variable "products_team" {
  type = set(string)
}

variable "leadership_team" {
  type = set(string)
}

variable "products_frontend_address" {
  type    = string
  default = ""
}

data "aws_instances" "eks" {
  instance_tags = {
    "eks:cluster-name" = local.eks_cluster_name
  }
}

locals {
  vpc_id                            = data.terraform_remote_state.infrastructure.outputs.vpc_id
  public_subnets                    = data.terraform_remote_state.infrastructure.outputs.public_subnets
  eks_cluster_name                  = data.terraform_remote_state.infrastructure.outputs.eks_cluster_name
  region                            = data.terraform_remote_state.infrastructure.outputs.region
  name                              = data.terraform_remote_state.infrastructure.outputs.hcp_boundary_cluster
  url                               = data.terraform_remote_state.infrastructure.outputs.hcp_boundary_endpoint
  username                          = data.terraform_remote_state.infrastructure.outputs.hcp_boundary_username
  password                          = data.terraform_remote_state.infrastructure.outputs.hcp_boundary_password
  eks_cluster_security_group_id     = data.terraform_remote_state.infrastructure.outputs.eks_cluster_security_group_id
  eks_target_ips                    = toset(data.aws_instances.eks.private_ips)
  vault_addr                        = data.terraform_remote_state.infrastructure.outputs.hcp_vault_public_address
  vault_namespace                   = data.terraform_remote_state.infrastructure.outputs.hcp_vault_namespace
  vault_token                       = data.terraform_remote_state.vault_setup.outputs.boundary_worker_token
  vault_boundary_path               = data.terraform_remote_state.vault_setup.outputs.boundary_worker_path
  vault_admin_token                 = data.terraform_remote_state.infrastructure.outputs.hcp_vault_token
  boundary_worker_mount             = data.terraform_remote_state.vault_setup.outputs.boundary_worker_path
  boundary_worker_security_group_id = data.terraform_remote_state.infrastructure.outputs.boundary_worker_security_group_id
  boundary_key_pair_name            = data.terraform_remote_state.infrastructure.outputs.boundary_worker_key_pair_name
  rds_security_group_id             = data.terraform_remote_state.infrastructure.outputs.database_security_group_id
}