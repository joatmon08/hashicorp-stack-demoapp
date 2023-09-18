variables {
  business_unit = "hashicups"
  environment   = "production"
  db_name       = "test"
}

provider "aws" {}

provider "vault" {}

provider "boundary" {
  ## possible bug with Boundary provider, not picking up BOUNDARY_ADDR
  addr = "https://effd00f1-c687-456d-8b7e-354f696a4c8b.boundary.hashicorp.cloud"
}

provider "consul" {
  address    = "https://hashicups.consul.11eaeb92-853e-2d98-8405-0242ac110009.aws.hashicorp.cloud"
  datacenter = "hashicups"
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
    condition     = data.vault_kv_secret_v2.postgres.data["username"] != null
    error_message = "Database in module should have admin credentials in Vault"
  }

  assert {
    condition     = length(data.consul_service_health.database.results) > 0
    error_message = "Database service not registered in Consul"
  }
}
