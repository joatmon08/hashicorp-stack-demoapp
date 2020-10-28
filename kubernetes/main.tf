resource "kubernetes_service_account" "vault_auth" {
  metadata {
    name = "vault-auth"
  }
}

resource "kubernetes_secret" "vault_auth" {
  metadata {
    name = "vault-auth"
    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account.vault_auth.metadata.0.name
    }
  }
  type = "kubernetes.io/service-account-token"
}

resource "kubernetes_cluster_role_binding" "token_review" {
  metadata {
    name = "role-tokenreview-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "system:auth-delegator"
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.vault_auth.metadata.0.name
    namespace = "default"
  }
}