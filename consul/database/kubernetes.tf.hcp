data "hcp_consul_agent_kubernetes_secret" "cluster" {
  cluster_id = local.hcp_consul_cluster_id
}

data "hcp_consul_agent_helm_config" "cluster" {
  cluster_id          = local.hcp_consul_cluster_id
  kubernetes_endpoint = replace(data.aws_eks_cluster.cluster.endpoint, "https://", "")
}

locals {
  consul_secrets    = yamldecode(data.hcp_consul_agent_kubernetes_secret.cluster.secret)
  consul_root_token = yamldecode(hcp_consul_cluster_root_token.token.kubernetes_secret)
}

resource "kubernetes_secret" "hcp_consul_secret" {
  metadata {
    name        = local.consul_secrets.metadata.name
    annotations = {}
    labels      = {}
  }

  data = {
    gossipEncryptionKey = base64decode(local.consul_secrets.data.gossipEncryptionKey)
    caCert              = base64decode(local.consul_secrets.data.caCert)
  }

  type = local.consul_secrets.type
}

resource "kubernetes_secret" "hcp_consul_token" {
  metadata {
    name        = local.consul_root_token.metadata.name
    annotations = {}
    labels      = {}
  }

  data = {
    token = base64decode(local.consul_root_token.data.token)
  }

  type = local.consul_root_token.type
}

resource "helm_release" "consul" {
  depends_on = [kubernetes_secret.hcp_consul_secret, kubernetes_secret.hcp_consul_token]
  name       = "consul"

  repository = "https://helm.releases.hashicorp.com"
  chart      = "consul"
  version    = var.consul_helm_version

  values = [
    data.hcp_consul_agent_helm_config.cluster.config
  ]

  set {
    name  = "global.image"
    value = "hashicorp/consul:${replace(data.hcp_consul_cluster.cluster.consul_version, "v", "")}"
  }

  set {
    name  = "controller.enabled"
    value = "true"
  }

  set {
    name  = "terminatingGateways.enabled"
    value = "true"
  }

  set {
    name  = "terminatingGateways.defaults.replicas"
    value = "1"
  }

  set {
    name  = "transparentProxy.defaultEnabled"
    value = "false"
  }
}
