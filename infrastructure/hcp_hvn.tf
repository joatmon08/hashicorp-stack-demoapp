locals {
  hcp_region = var.hcp_region == "" ? var.region : var.hcp_region
}

resource "hcp_hvn" "main" {
  hvn_id         = var.name
  cloud_provider = "aws"
  region         = local.hcp_region
  cidr_block     = var.hcp_cidr_block

  lifecycle {
    precondition {
      condition     = var.hcp_cidr_block != var.vpc_cidr_block
      error_message = "HCP HVN must not overlap with VPC CIDR block"
    }
  }

}