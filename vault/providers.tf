terraform {
  required_version = "~> 0.14"
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 2.19"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "vault" {}

provider "aws" {
  region = var.region == "" ? data.terraform_remote_state.infrastructure.outputs.region : var.region
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}