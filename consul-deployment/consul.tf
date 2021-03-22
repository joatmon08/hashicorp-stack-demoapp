resource "consul_service" "database" {
  depends_on = [helm_release.consul]
  name       = "database"
  node       = consul_node.database.name
  port       = 5432
  tags       = ["external"]
  check {
    check_id = "service:database"
    name     = "Postgres health check"
    status   = "passing"
    tcp      = "${local.products_database}:5432"
    interval = "30s"
    timeout  = "3s"
  }
}

resource "consul_node" "database" {
  depends_on = [helm_release.consul]
  name       = "database"
  address    = local.products_database

  meta = {
    "external-node"  = "true"
    "external-probe" = "true"
  }
}

resource "consul_config_entry" "database" {
  name = "database"
  kind = "service-defaults"

  config_json = jsonencode({
    Protocol = "tcp"
  })
}

resource "consul_config_entry" "terminating_gateway" {
  name = "terminating-gateway"
  kind = "terminating-gateway"

  config_json = jsonencode({
    Services = [{
      Name = "database"
    }]
  })
}

# resource "kubernetes_manifest" "database_terminating_gateway" {
#   provider   = kubernetes-alpha
#   depends_on = [consul_service.database]
#   manifest = {
#     "apiVersion" = "consul.hashicorp.com/v1alpha1"
#     "kind"       = "TerminatingGateway"
#     "metadata" = {
#       "name"      = "terminating-gateway"
#       "namespace" = "default"
#     }
#     "spec" = {
#       "services" = [
#         {
#           "name" = "database"
#         },
#       ]
#     }
#   }
# }