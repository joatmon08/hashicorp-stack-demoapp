terraform {
  required_version = "~> 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.40"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.27"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }

    hcp = {
      source  = "hashicorp/hcp"
      version = "~> 0.83"
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
