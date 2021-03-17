terraform {
  required_version = "~> 0.14"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.32"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 1.13"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 3.0"
    }
    boundary = {
      source  = "hashicorp/boundary"
      version = "~> 1.0"
    }
    hcp = {
      source  = "hashicorp/hcp"
      version = "~> 0.2"
    }
  }
}

provider "aws" {
  region = var.region
}

provider "hcp" {}