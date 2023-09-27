terraform {
  required_version = "~> 1.0"
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.6"
    }
  }
}

provider "vault" {
  address   = local.vault_address
  token     = local.vault_token
  namespace = local.vault_namespace
}