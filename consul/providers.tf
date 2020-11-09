terraform {
  required_version = "~>0.13"
  required_providers {
    consul = {
      source  = "hashicorp/consul"
      version = "~> 2.10.1"
    }
  }
  backend "remote" {}
}

provider "consul" {}