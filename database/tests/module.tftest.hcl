variables {
  business_unit = "hashicups"
  environment   = "production"
  db_name       = "test"
}

provider "aws" {}

provider "vault" {}

provider "boundary" {
  ## possible bug with Boundary provider, not picking up BOUNDARY_ADDR
  addr = "https://444e3b7d-35d6-4858-a82d-c99842fb0297.boundary.hashicorp.cloud"
}

run "setup" {
  command = apply
}

run "database" {
  command = plan

  assert {
    condition     = !aws_db_instance.database.publicly_accessible
    error_message = "Database in module should not be publicly accessible"
  }

  assert {
    condition     = aws_db_instance.database.storage_encrypted
    error_message = "Database in module should be encrypted"
  }

  assert {
    condition     = aws_db_instance.database.status == "available"
    error_message = "Database in module should be available"
  }

  assert {
    condition     = data.vault_generic_secret.database.data["username"] == aws_db_instance.database.username
    error_message = "Database in module should have admin credentials in Vault"
  }
}
