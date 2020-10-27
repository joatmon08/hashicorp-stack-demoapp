terraform {
  required_version = "~>0.13"
  required_providers {
    aws = {
      version = "~>3.11.0"
    }
    boundary = {
      source  = "hashicorp/boundary"
      version = "~> 0.1.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0.0"
    }
  }
  backend "remote" {}
}

provider "aws" {
  region = var.region
}

data "aws_instances" "eks" {
  instance_tags = {
    "eks:cluster-name" = var.eks_cluster_name
  }
}

module "boundary" {
  source              = "./module"
  url                 = var.boundary_endpoint
  target_ips          = data.aws_instances.eks.private_ips
  kms_recovery_key_id = var.boundary_kms_recovery_key_id
  region              = var.region
}

output "boundary_endpoint" {
  value = var.boundary_endpoint
}

output "boundary_auth_method_id" {
  value = module.boundary.auth_method_id
}

output "boundary_password" {
  value     = module.boundary.backend_team_password
  sensitive = true
}

output "boundary_target" {
  value = module.boundary.backend_target
}