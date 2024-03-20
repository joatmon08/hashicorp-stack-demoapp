resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "hcp_service_principal" "argocd" {
  name = "argocd"
}

resource "hcp_service_principal_key" "argocd" {
  service_principal = hcp_service_principal.argocd.resource_name
}

resource "hcp_project_iam_binding" "argocd" {
  project_id   = var.hcp_project_id
  principal_id = hcp_service_principal.argocd.resource_id
  role         = "roles/viewer"
}

resource "kubernetes_secret" "hvs_service_principal" {
  metadata {
    name      = "hvs-service-principal"
    namespace = kubernetes_namespace.argocd.metadata.0.name
  }

  data = {
    clientID     = hcp_service_principal_key.argocd.client_id
    clientSecret = hcp_service_principal_key.argocd.client_secret
  }
}

resource "kubernetes_manifest" "hvs_auth" {
  manifest = {
    "apiVersion" = "secrets.hashicorp.com/v1beta1"
    "kind"       = "HCPAuth"
    "metadata" = {
      "name"      = "default"
      "namespace" = kubernetes_namespace.argocd.metadata.0.name
    }
    "spec" = {
      "organizationID" = var.hcp_organization_id
      "projectID"      = var.hcp_project_id
      "servicePrincipal" = {
        "secretRef" = kubernetes_secret.hvs_service_principal.metadata.0.name
      }
    }
  }
}

# resource "kubernetes_manifest" "hvs_github_creds" {
#   manifest = {
#     "apiVersion" = "secrets.hashicorp.com/v1beta1"
#     "kind"       = "HCPVaultSecretsApp"
#     "metadata" = {
#       "name"      = "github-creds"
#       "namespace" = kubernetes_namespace.argocd.metadata.0.name
#     }
#     "spec" = {
#       "hcpAuthRef" = kubernetes_manifest.hvs_auth.manifest.metadata.name
#       "appName"    = "argocd"
#       "destination" = {
#         "create" = true
#         "labels" = {
#           "argocd.argoproj.io/secret-type" = "repository"
#           "hvs"                            = "true"
#         }
#         "name" = "github-creds"
#         "transformation" = {
#           "templates" = {
#             githubAppID = {
#               name = "githubAppID"
#               text = "{{- get .Secrets \"githubAppID\" -}}"
#             },
#             githubAppInstallationID = {
#               name = "githubAppInstallationID"
#               text = "{{- get .Secrets \"githubAppInstallationID\" -}}"
#             },
#             githubAppPrivateKey = {
#               name = "githubAppPrivateKey"
#               text = "{{- get .Secrets \"githubAppPrivateKey\" -}}"
#             },
#             type = {
#               name = "type"
#               text = "git"
#             },
#             url = {
#               name = "url"
#               text = "{{- get .Secrets \"url\" -}}"
#             },
#           }
#         }
#       }
#       "refreshAfter" = "1h"
#     }
#   }
# }


resource "helm_release" "argocd" {
  name       = "argocd"
  namespace  = kubernetes_namespace.argocd.metadata.0.name
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.argocd_helm_version

  values = [
    file("templates/values.yaml")
  ]
}