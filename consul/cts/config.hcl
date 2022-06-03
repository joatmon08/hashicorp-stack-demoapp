log_level   = "INFO"
working_dir = "sync-tasks"
port        = 8558

syslog {}

buffer_period {
  enabled = true
  min     = "30s"
  max     = "60s"
}

driver "terraform" {
  log         = false
  persist_log = false

  backend "consul" {
    gzip = true
  }
}

task {
  name        = "products-database"
  description = "Task to create database secrets engine for product PostgreSQL database"
  module      = "github.com/joatmon08/terraform-vault-postgres-nia"

  variable_files = ["secrets.auto.tfvars"]

  condition "services" {
    names      = ["database"]
    datacenter = "dc1"
  }
}