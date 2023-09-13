resource "kubernetes_manifest" "appproject_argocd_consul" {
  depends_on = [ helm_release.argocd ]
  manifest = {
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind" = "AppProject"
    "metadata" = {
      "finalizers" = [
        "resources-finalizer.argocd.argoproj.io",
      ]
      "name" = "consul"
      "namespace" = "argocd"
    }
    "spec" = {
      "clusterResourceWhitelist" = [
        {
          "group" = ""
          "kind" = "Namespace"
        },
        {
          "group" = "rbac.authorization.k8s.io"
          "kind" = "ClusterRole"
        },
        {
          "group" = "rbac.authorization.k8s.io"
          "kind" = "ClusterRoleBinding"
        },
        {
          "group" = "apiextensions.k8s.io"
          "kind" = "CustomResourceDefinition"
        },
        {
          "group" = "admissionregistration.k8s.io"
          "kind" = "MutatingWebhookConfiguration"
        },
      ]
      "description" = "HashiCorp Consul Configuration"
      "destinations" = [
        {
          "name" = "in-cluster"
          "namespace" = "consul"
          "server" = "https://kubernetes.default.svc"
        },
        {
          "name" = "in-cluster"
          "namespace" = "argocd"
          "server" = "https://kubernetes.default.svc"
        },
      ]
      "orphanedResources" = {
        "warn" = false
      }
      "roles" = [
        {
          "description" = "Read-only privileges to consul"
          "groups" = [
            "consul",
          ]
          "name" = "read-only"
          "policies" = [
            "p, proj:consul:read-only, applications, get, consul/*, allow",
          ]
        },
      ]
      "sourceRepos" = [
        "https://github.com/joatmon08/hashicorp-stack-demoapp.git",
      ]
    }
  }
}
