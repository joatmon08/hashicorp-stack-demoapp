# data "hcp_consul_agent_kubernetes_secret" "cluster" {
#   cluster_id = local.hcp_consul_cluster_id
# }

# data "hcp_consul_agent_helm_config" "cluster" {
#   cluster_id          = local.hcp_consul_cluster_id
#   kubernetes_endpoint = replace(data.aws_eks_cluster.cluster.endpoint, "https://", "")
# }

# locals {
#   consul_secrets = yamldecode(data.hcp_consul_agent_kubernetes_secret.cluster.secret)
#   consul_token   = yamldecode(hcp_consul_cluster_root_token.token.kubernetes_secret)
# }

# resource "kubernetes_secret" "hcp_consul_secret" {
#   metadata {
#     name = local.consul_secrets.metadata.name
#   }

#   data = {
#     gossipEncryptionKey = base64decode(local.consul_secrets.data.gossipEncryptionKey)
#     caCert              = base64decode(local.consul_secrets.data.caCert)
#   }

#   type = local.consul_secrets.type
# }

# resource "kubernetes_secret" "hcp_consul_token" {
#   metadata {
#     name = local.consul_token.metadata.name
#   }

#   data = {
#     token = base64decode(local.consul_token.data.token)
#   }

#   type = local.consul_token.type
# }

# resource "kubernetes_secret" "consul_client" {
#   metadata {
#     name = "consul-client-acl-token"
#   }

#   data = {
#     token = base64decode(local.consul_token.data.token)
#   }

#   type = local.consul_token.type
# }

# resource "helm_release" "consul" {
#   depends_on = [kubernetes_secret.hcp_consul_secret, kubernetes_secret.hcp_consul_token, kubernetes_secret.consul_client]
#   name       = "consul"

#   chart = "https://github.com/hashicorp/consul-helm/archive/${var.consul_helm_version}.tar.gz"

#   values = [
#     data.hcp_consul_agent_helm_config.cluster.config
#   ]

#   set {
#     name  = "controller.enabled"
#     value = "true"
#   }

#   set {
#     name  = "terminatingGateways.enabled"
#     value = "true"
#   }
# }