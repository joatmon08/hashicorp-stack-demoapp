terraform {
  required_version = "~> 1.0"
  required_providers {
    boundary = {
      source  = "hashicorp/boundary"
      version = "~> 1.0"
    }
  }
}

provider "aws" {
  region = local.region
}

provider "boundary" {
  addr                            = local.url
  password_auth_method_login_name = local.username
  password_auth_method_password   = local.password
}
