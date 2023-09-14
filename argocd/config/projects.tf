resource "kubernetes_manifest" "appproject_argocd_consul" {
  manifest = {
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "AppProject"
    "metadata" = {
      "finalizers" = [
        "resources-finalizer.argocd.argoproj.io",
      ]
      "name"      = "consul"
      "namespace" = "argocd"
    }
    "spec" = {
      "clusterResourceWhitelist" = [
        {
          "group" = ""
          "kind"  = "Namespace"
        },
        {
          "group" = "rbac.authorization.k8s.io"
          "kind"  = "ClusterRole"
        },
        {
          "group" = "rbac.authorization.k8s.io"
          "kind"  = "ClusterRoleBinding"
        },
        {
          "group" = "apiextensions.k8s.io"
          "kind"  = "CustomResourceDefinition"
        },
        {
          "group" = "admissionregistration.k8s.io"
          "kind"  = "MutatingWebhookConfiguration"
        },
      ]
      "description" = "HashiCorp Consul Configuration"
      "destinations" = [
        {
          "name"      = "in-cluster"
          "namespace" = "consul"
          "server"    = "https://kubernetes.default.svc"
        },
        {
          "name"      = "in-cluster"
          "namespace" = "argocd"
          "server"    = "https://kubernetes.default.svc"
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

resource "kubernetes_manifest" "appproject_argocd_tfc_operator" {
  manifest = {
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "AppProject"
    "metadata" = {
      "finalizers" = [
        "resources-finalizer.argocd.argoproj.io",
      ]
      "name"      = "terraform-cloud-operator"
      "namespace" = "argocd"
    }
    "spec" = {
      "clusterResourceWhitelist" = [
        {
          "group" = ""
          "kind"  = "Namespace"
        },
        {
          "group" = "rbac.authorization.k8s.io"
          "kind"  = "ClusterRole"
        },
        {
          "group" = "rbac.authorization.k8s.io"
          "kind"  = "ClusterRoleBinding"
        },
        {
          "group" = "apiextensions.k8s.io"
          "kind"  = "CustomResourceDefinition"
        },
        {
          "group" = "admissionregistration.k8s.io"
          "kind"  = "MutatingWebhookConfiguration"
        },
      ]
      "description" = "HashiCorp Terraform Cloud Operator Configuration"
      "destinations" = [
        {
          "name"      = "in-cluster"
          "namespace" = "terraform-cloud-operator"
          "server"    = "https://kubernetes.default.svc"
        },
        {
          "name"      = "in-cluster"
          "namespace" = "argocd"
          "server"    = "https://kubernetes.default.svc"
        },
      ]
      "orphanedResources" = {
        "warn" = false
      }
      "roles" = [
        {
          "description" = "Read-only privileges to terraform-cloud-operator"
          "groups" = [
            "terraform-cloud-operator",
          ]
          "name" = "read-only"
          "policies" = [
            "p, proj:terraform-cloud-operator:read-only, applications, get, terraform-cloud-operator/*, allow",
          ]
        },
      ]
      "sourceRepos" = [
        "https://github.com/joatmon08/hashicorp-stack-demoapp.git",
        "https://helm.releases.hashicorp.com"
      ]
    }
  }
}
