# resource "consul_service" "database" {
#   name = "database"
#   node = consul_node.database.name
#   port = 5432
#   tags = ["external"]
#   meta = {}

#   check {
#     check_id = "service:postgres"
#     name     = "Postgres health check"
#     status   = "passing"
#     tcp      = "${local.products_database}:5432"
#     interval = "30s"
#     timeout  = "3s"
#   }
# }

# resource "consul_node" "database" {
#   name    = "database"
#   address = local.products_database

#   meta = {
#     "external-node"  = "true"
#     "external-probe" = "true"
#   }
# }

# resource "kubernetes_manifest" "service_defaults_database" {
#   manifest = {
#     "apiVersion" = "consul.hashicorp.com/v1alpha1"
#     "kind"       = "ServiceDefaults"
#     "metadata" = {
#       "name"      = "database"
#       "namespace" = var.namespace
#     }
#     "spec" = {
#       "protocol" = "tcp"
#     }
#   }
# }

# resource "kubernetes_manifest" "terminating_gateway_database" {
#   manifest = {
#     "apiVersion" = "consul.hashicorp.com/v1alpha1"
#     "kind"       = "TerminatingGateway"
#     "metadata" = {
#       "name"      = "terminating-gateway"
#       "namespace" = var.namespace
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