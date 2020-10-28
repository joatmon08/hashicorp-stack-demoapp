terraform {
  required_version = "~>0.13"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 1.13.3"
    }
  }
  backend "remote" {}
}

provider "kubernetes" {}