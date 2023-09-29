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
  }
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