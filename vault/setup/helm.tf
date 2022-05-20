resource "helm_release" "vault" {
  name       = "vault"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"
  version    = var.vault_helm_version

  set {
    name  = "injector.enabled"
    value = "true"
  }

  set {
    name  = "injector.externalVaultAddr"
    value = data.hcp_vault_cluster.cluster.vault_private_endpoint_url
  }
}