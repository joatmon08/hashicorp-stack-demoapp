data "hcp_consul_agent_kubernetes_secret" "cluster" {
  cluster_id = local.hcp_consul_cluster_id
}

data "hcp_consul_agent_helm_config" "cluster" {
  cluster_id          = local.hcp_consul_cluster_id
  kubernetes_endpoint = replace(data.aws_eks_cluster.cluster.endpoint, "https://", "")
}

data "hcp_consul_cluster" "cluster" {
  cluster_id = local.hcp_consul_cluster_id
}

resource "hcp_consul_cluster_root_token" "token" {
  cluster_id = local.hcp_consul_cluster_id
}

locals {
  consul_secrets    = yamldecode(data.hcp_consul_agent_kubernetes_secret.cluster.secret)
  consul_root_token = yamldecode(hcp_consul_cluster_root_token.token.kubernetes_secret)
}

resource "kubernetes_secret" "hcp_consul_secret" {
  count = var.use_hcp_consul ? 1 : 0
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
  count = var.use_hcp_consul ? 1 : 0
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

resource "helm_release" "consul_hcp" {
  count      = var.use_hcp_consul ? 1 : 0
  depends_on = [kubernetes_secret.hcp_consul_secret, kubernetes_secret.hcp_consul_token]
  name       = "consul"

  repository = "https://helm.releases.hashicorp.com"
  chart      = "consul"
  version    = var.consul_helm_version

  values = [
    data.hcp_consul_agent_helm_config.cluster.config,
    file("templates/hcp.yaml")
  ]

  set {
    name  = "global.image"
    value = "hashicorp/consul:${replace(data.hcp_consul_cluster.cluster.consul_version, "v", "")}"
  }
}
