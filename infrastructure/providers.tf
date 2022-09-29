terraform {
  required_version = "~> 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.32"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.13"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }

    hcp = {
      source  = "hashicorp/hcp"
      version = "~> 0.45"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = var.tags
  }
}

provider "hcp" {}
