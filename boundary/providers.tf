terraform {
  required_version = "~> 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=4.14,< 5.0"
    }

    boundary = {
      source  = "hashicorp/boundary"
      version = "~> 1.0"
    }

    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.17"
    }
  }
}

provider "aws" {
  region = local.region
}

provider "boundary" {
  addr                   = local.url
  auth_method_login_name = local.username
  auth_method_password   = local.password
}

provider "vault" {
  address   = local.vault_addr
  namespace = local.vault_namespace
  token     = local.vault_admin_token
}