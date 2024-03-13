terraform {
  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.52"
    }
  }
}

provider "tfe" {}