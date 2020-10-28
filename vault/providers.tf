terraform {
  required_version = "~>0.13"
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 2.15.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 1.13.3"
    }
  }
  backend "remote" {}
}

provider "vault" {}

provider "kubernetes" {}