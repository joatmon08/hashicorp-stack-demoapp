resource "consul_service" "database" {
  name = "database"
  node = consul_node.database.name
  port = 5432
  tags = ["external"]
  meta = {}

  check {
    check_id = "service:postgres"
    name     = "Postgres health check"
    status   = "passing"
    tcp      = "${var.products_database}:5432"
    interval = "30s"
    timeout  = "3s"
  }
}

resource "consul_node" "database" {
  name    = "database"
  address = var.products_database

  meta = {
    "external-node"  = "true"
    "external-probe" = "true"
  }
}