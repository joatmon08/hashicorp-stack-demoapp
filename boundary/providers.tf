terraform {
  required_version = "~> 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=4.14,< 5.0"
    }
    boundary = {
      source  = "hashicorp/boundary"
      version = "1.0.6"
    }
  }
}

provider "aws" {
  region = local.region
}

provider "boundary" {
  addr             = local.url
  recovery_kms_hcl = <<EOT
kms "awskms" {
	purpose    = "recovery"
  region = "${local.region}"
	key_id     = "global_root"
  kms_key_id = "${local.kms_recovery_key_id}"
}
EOT
}
