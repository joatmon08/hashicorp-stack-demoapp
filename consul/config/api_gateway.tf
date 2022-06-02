locals {
  consul_api_gateway_secret_name = "consul-api-gateway"
}

resource "kubernetes_service_account" "consul_api_gateway" {
  metadata {
    name      = "consul-api-gateway"
    namespace = var.namespace
  }
  automount_service_account_token = true
}

resource "kubernetes_manifest" "consul_api_gateway_secret_provider" {
  depends_on = [
    kubernetes_service_account.consul_api_gateway
  ]
  manifest = {
    "apiVersion" = "secrets-store.csi.x-k8s.io/v1"
    "kind"       = "SecretProviderClass"
    "metadata" = {
      "name"      = local.consul_api_gateway_secret_name
      "namespace" = var.namespace
    }
    "spec" = {
      "parameters" = {
        "objects"        = <<-EOT
      - objectName: "consul-api-gateway-ca-cert"
        method: "POST"
        secretPath: "consul/gateway/pki_int/issue/${kubernetes_service_account.consul_api_gateway.metadata.0.name}"
        secretKey: "certificate"
        secretArgs:
          common_name: "test.hashiconf.com"
      - objectName: "consul-api-gateway-ca-key"
        method: "POST"
        secretPath: "consul/gateway/pki_int/issue/${kubernetes_service_account.consul_api_gateway.metadata.0.name}"
        secretKey: "private_key"
        secretArgs:
          common_name: "test.hashiconf.com"
      EOT
        "roleName"       = kubernetes_service_account.consul_api_gateway.metadata.0.name
        "vaultAddress"   = local.vault_addr
        "vaultNamespace" = "admin"
      }
      "provider" = "vault"
      "secretObjects" = [
        {
          "data" = [
            {
              "key"        = "tls.crt"
              "objectName" = "consul-api-gateway-ca-cert"
            },
            {
              "key"        = "tls.key"
              "objectName" = "consul-api-gateway-ca-key"
            },
          ]
          "secretName" = "consul-api-gateway-cert"
          "type"       = "kubernetes.io/tls"
        },
      ]
    }
  }
}

resource "kubernetes_manifest" "secret_provider_pki" {
  depends_on = [
    kubernetes_manifest.consul_api_gateway_secret_provider
  ]
  manifest = {
    "apiVersion" = "apps/v1"
    "kind"       = "Deployment"
    "metadata" = {
      "labels" = {
        "app" = "secrets-store-inline"
      }
      "name"      = "secrets-store-inline"
      "namespace" = var.namespace
    }
    "spec" = {
      "replicas" = 1
      "selector" = {
        "matchLabels" = {
          "app" = "secrets-store-inline"
        }
      }
      "template" = {
        "metadata" = {
          "labels" = {
            "app" = "secrets-store-inline"
          }
        }
        "spec" = {
          "containers" = [
            {
              "command" = [
                "/bin/sleep",
                "10000",
              ]
              "image" = "k8s.gcr.io/e2e-test-images/busybox:1.29"
              "name"  = "busybox"
              "volumeMounts" = [
                {
                  "mountPath" = "/mnt/secrets-store"
                  "name"      = "secrets-store"
                  "readOnly"  = true
                },
              ]
            },
          ]
          "serviceAccountName" = kubernetes_service_account.consul_api_gateway.metadata.0.name
          "volumes" = [
            {
              "csi" = {
                "driver"   = "secrets-store.csi.k8s.io"
                "readOnly" = true
                "volumeAttributes" = {
                  "secretProviderClass" = local.consul_api_gateway_secret_name
                }
              }
              "name" = "secrets-store"
            },
          ]
        }
      }
    }
  }
}

# resource "kubernetes_manifest" "api_gateway" {
#   manifest = {
#     "apiVersion" = "gateway.networking.k8s.io/v1alpha2"
#     "kind"       = "Gateway"
#     "metadata" = {
#       "name"      = "api-gateway"
#       "namespace" = var.namespace
#     }
#     "spec" = {
#       "gatewayClassName" = "consul-api-gateway"
#       "listeners" = [
#         {
#           "allowedRoutes" = {
#             "namespaces" = {
#               "from" = "Same"
#             }
#           }
#           "name"     = "https"
#           "port"     = 8443
#           "protocol" = "HTTPS"
#           "tls" = {
#             "certificateRefs" = [
#               {
#                 "name" = "consul-server-cert"
#               },
#             ]
#           }
#         },
#       ]
#     }
#   }
# }