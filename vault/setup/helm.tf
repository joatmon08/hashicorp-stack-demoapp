resource "helm_release" "csi" {
  name       = "csi"
  namespace  = "kube-system"
  repository = "https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts"
  chart      = "secrets-store-csi-driver"
  version    = var.csi_helm_version

  set {
    name  = "enableSecretRotation"
    value = "true"
  }

  set {
    name  = "syncSecret.enabled"
    value = "true"
  }
}

resource "helm_release" "vault" {
  depends_on       = [helm_release.csi]
  name             = "vault"
  namespace        = "vault"
  create_namespace = true

  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"
  version    = var.vault_helm_version

  set {
    name  = "injector.enabled"
    value = "true"
  }

  set {
    name  = "injector.externalVaultAddr"
    value = local.hcp_vault_private_address
  }

  set {
    name  = "csi.enabled"
    value = "true"
  }
}

resource "helm_release" "vault_operator" {
  depends_on       = [helm_release.vault]
  name             = "vault-secrets-operator"
  namespace        = "vault-secrets-operator"
  create_namespace = true

  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault-secrets-operator"
  version    = var.vault_operator_helm_version

  set {
    name  = "defaultVaultConnection.enabled"
    value = "true"
  }

  set {
    name  = "defaultVaultConnection.address"
    value = local.hcp_vault_private_address
  }
}