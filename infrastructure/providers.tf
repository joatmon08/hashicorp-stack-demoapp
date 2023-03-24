terraform {
  required_version = "~> 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=4.14,< 5.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.11"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 3.4"
    }

    hcp = {
      source  = "hashicorp/hcp"
      version = "~> 0.29"
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
