terraform {
  required_version = "~> 1.0"
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.8"
    }
    consul = {
      source  = "hashicorp/consul"
      version = "~> 2.18"
    }
  }
}

provider "vault" {
  address   = local.hcp_vault_public_address
  token     = local.hcp_vault_cluster_token
  namespace = local.hcp_vault_namespace
}

provider "consul" {
  address = local.hcp_consul_public_address
  token   = local.hcp_consul_token
}