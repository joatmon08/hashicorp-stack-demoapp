resource "random_string" "boundary" {
  length  = 4
  upper   = false
  special = false
  numeric = false
}

resource "random_password" "boundary" {
  length      = 16
  min_upper   = 2
  min_lower   = 2
  min_numeric = 2
  min_special = 1
}

resource "hcp_boundary_cluster" "main" {
  cluster_id = var.name
  username   = "${var.name}-${random_string.boundary.result}"
  password   = random_password.boundary.result
  tier       = var.hcp_boundary_tier

  lifecycle {
    precondition {
      condition     = random_string.boundary.length > 3
      error_message = "HCP Boundary requires username to be at least 3 characters in length"
    }

    precondition {
      condition     = random_password.boundary.length > 8
      error_message = "HCP Boundary requires password to be at least 8 characters in length"
    }
  }
}

resource "tls_private_key" "boundary" {
  algorithm = "RSA"
}

resource "aws_key_pair" "boundary" {
  key_name   = var.name
  public_key = trimspace(tls_private_key.boundary.public_key_openssh)
  tags = {
    Purpose = "boundary"
  }
}

resource "aws_security_group" "boundary_worker" {
  vpc_id = module.vpc.vpc_id
  tags = {
    Purpose = "boundary"
  }
}