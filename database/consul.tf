resource "consul_service" "database" {
  name = "${var.business_unit}-database"
  node = consul_node.database.name
  port = 5432
  tags = ["external"]
  meta = {}

  check {
    check_id = "service:postgres"
    name     = "Postgres health check"
    status   = "passing"
    tcp      = "${aws_db_instance.database.address}:5432"
    interval = "30s"
    timeout  = "3s"
  }
}

resource "consul_node" "database" {
  name    = "${var.business_unit}-database"
  address = aws_db_instance.database.address

  meta = {
    "external-node"  = "true"
    "external-probe" = "true"
  }
}

resource "consul_config_entry" "service_defaults" {
  name = "${var.business_unit}-database"
  kind = "service-defaults"

  config_json = jsonencode({
    Protocol = "tcp"
  })
}

data "consul_service_health" "database" {
  name    = consul_service.database.name
  passing = true
}