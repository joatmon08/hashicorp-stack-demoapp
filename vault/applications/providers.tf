terraform {
  required_version = "~> 1.0"
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.6"
    }
    consul = {
      source  = "hashicorp/consul"
      version = "~> 2.18"
    }
    boundary = {
      source  = "hashicorp/boundary"
      version = "~> 1.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = local.region
}

provider "vault" {
  address   = local.vault_address
  token     = local.vault_token
  namespace = local.vault_namespace
}

provider "consul" {
  address    = local.consul_address
  token      = local.consul_token
  datacenter = local.consul_datacenter
}

provider "boundary" {
  addr                   = local.boundary_address
  auth_method_login_name = local.boundary_username
  auth_method_password   = local.boundary_password
}