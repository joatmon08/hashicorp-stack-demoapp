locals {
  boundary_access_cluster_role = "boundary"
}

resource "kubernetes_manifest" "cluster_role_boundary_access" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind"       = "ClusterRole"
    "metadata" = {
      "name" = local.boundary_access_cluster_role
    }
    "rules" = [
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "namespaces",
        ]
        "verbs" = [
          "get",
        ]
      },
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "serviceaccounts",
          "serviceaccounts/token",
        ]
        "verbs" = [
          "create",
          "update",
          "delete",
        ]
      },
      {
        "apiGroups" = [
          "rbac.authorization.k8s.io",
        ]
        "resources" = [
          "rolebindings",
          "clusterrolebindings",
        ]
        "verbs" = [
          "create",
          "update",
          "delete",
        ]
      },
      {
        "apiGroups" = [
          "rbac.authorization.k8s.io",
        ]
        "resources" = [
          "roles",
          "clusterroles",
        ]
        "verbs" = [
          "bind",
          "escalate",
          "create",
          "update",
          "delete",
        ]
      },
    ]
  }
}

resource "kubernetes_manifest" "cluster_role_binding_boundary_access" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind"       = "ClusterRoleBinding"
    "metadata" = {
      "name" = "vault-token-creator-binding"
    }
    "roleRef" = {
      "apiGroup" = "rbac.authorization.k8s.io"
      "kind"     = "ClusterRole"
      "name"     = local.boundary_access_cluster_role
    }
    "subjects" = [
      {
        "kind"      = "ServiceAccount"
        "name"      = kubernetes_secret.vault_auth.metadata.0.name
        "namespace" = kubernetes_secret.vault_auth.metadata.0.namespace
      },
    ]
  }
}

resource "vault_kubernetes_secret_backend" "boundary" {
  path                      = "kubernetes"
  description               = "Kubernetes secret engine for Boundary to access Kubernetes"
  default_lease_ttl_seconds = 3600
  max_lease_ttl_seconds     = 7200
  kubernetes_host           = local.kubernetes_host
  kubernetes_ca_cert        = kubernetes_secret.vault_auth.data["ca.crt"]
  service_account_jwt       = kubernetes_secret.vault_auth.data.token
  disable_local_ca_jwt      = false
}

resource "vault_kubernetes_secret_backend_role" "kuberrnetes" {
  backend                       = vault_kubernetes_secret_backend.boundary.path
  name                          = local.boundary_access_cluster_role
  allowed_kubernetes_namespaces = ["*"]
  token_max_ttl                 = 7200
  token_default_ttl             = 3600
  generated_role_rules          = <<EOT
{"rules":[{"apiGroups":[""],"resources":["pods"],"verbs":["list"]}]}
EOT
}