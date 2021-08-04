resource "consul_service" "database" {
  name = "database"
  node = consul_node.database.name
  port = 5432
  tags = ["external"]
  check {
    check_id = "service:postgres"
    name     = "Postgres health check"
    status   = "passing"
    tcp      = "${local.products_database}:5432"
    interval = "30s"
    timeout  = "3s"
  }
}

resource "consul_node" "database" {
  name    = "database"
  address = local.products_database

  meta = {
    "external-node"  = "true"
    "external-probe" = "true"
  }
}

resource "consul_config_entry" "database" {
  name = "database"
  kind = "service-defaults"

  config_json = jsonencode({
    Protocol    = "tcp"
    Expose      = {}
    MeshGateway = {}
    Namespace   = "default"
  })
}

resource "consul_config_entry" "service_intentions" {
  name = "*"
  kind = "service-intentions"

  config_json = jsonencode({
    Sources = [
      {
        Action     = "deny"
        Name       = "*"
        Precedence = 1
        Type       = "consul"
      }
    ]
  })
}

resource "consul_acl_policy" "database" {
  name  = "database-write-policy"
  rules = <<-RULE
    service "database" {
        policy = "write"
    }
    RULE
}