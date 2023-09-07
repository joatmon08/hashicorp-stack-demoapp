resource "helm_release" "argocd" {
  name       = "argocd"
  namespace  = "default"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.argocd_helm_version

  values = [
    file("templates/values.yaml")
  ]
}