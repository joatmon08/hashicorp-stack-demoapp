resource "kubernetes_manifest" "service_defaults_database" {
  manifest = {
    "apiVersion" = "consul.hashicorp.com/v1alpha1"
    "kind"       = "ServiceDefaults"
    "metadata" = {
      "name"      = "database"
      "namespace" = "default"
    }
    "spec" = {
      "protocol" = "tcp"
    }
  }
}

resource "kubernetes_manifest" "terminating_gateway_database" {
  manifest = {
    "apiVersion" = "consul.hashicorp.com/v1alpha1"
    "kind"       = "TerminatingGateway"
    "metadata" = {
      "name"      = "terminating-gateway"
      "namespace" = "default"
    }
    "spec" = {
      "services" = [
        {
          "name" = "database"
        },
      ]
    }
  }
}