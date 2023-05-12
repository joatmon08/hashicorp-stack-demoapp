resource "random_string" "boundary" {
  length  = 4
  upper   = false
  special = false
  numeric = false

  lifecycle {
    precondition {
      condition     = random_password.database.length > 3
      error_message = "HCP Boundary requires username to be at least 3 characters in length"
    }
  }

}

resource "random_password" "boundary" {
  length      = 16
  min_upper   = 2
  min_lower   = 2
  min_numeric = 2
  min_special = 1

  lifecycle {
    precondition {
      condition     = random_password.database.length > 8
      error_message = "HCP Boundary requires password to be at least 8 characters in length"
    }
  }

}

resource "hcp_boundary_cluster" "main" {
  cluster_id = var.name
  username   = "${var.name}-${random_string.boundary.result}"
  password   = random_password.boundary.result
}