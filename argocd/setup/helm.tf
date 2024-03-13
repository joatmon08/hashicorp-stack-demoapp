resource "helm_release" "argocd" {
  name             = "argocd"
  namespace        = "argocd"
  create_namespace = true
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.argocd_helm_version

  values = [
    file("templates/values.yaml")
  ]
}

resource "helm_release" "terraform_cloud_operator" {
  name             = "terraform-cloud-operator"
  namespace        = "terraform-cloud-operator"
  create_namespace = true
  repository       = "https://helm.releases.hashicorp.com"
  chart            = "terraform-cloud-operator"
  version          = var.terraform_cloud_operator_version
}