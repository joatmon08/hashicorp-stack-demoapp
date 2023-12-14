resource "boundary_target" "eks_nodes_ssh" {
  type                     = "tcp"
  name                     = "eks-ssh"
  description              = "EKS Nodes SSH target"
  scope_id                 = boundary_scope.core_infra.id
  ingress_worker_filter    = "\"eks\" in \"/tags/type\""
  egress_worker_filter     = "\"${local.name}\" in \"/tags/type\""
  session_connection_limit = 3
  default_port             = 22
  host_source_ids = [
    boundary_host_set_static.eks_nodes.id
  ]
  brokered_credential_source_ids = [
    boundary_credential_library_vault.eks_nodes.id
  ]
}

resource "boundary_credential_store_vault" "eks_nodes" {
  name        = "vault-${boundary_scope.core_infra.name}"
  description = "Vault credentials store for ${boundary_scope.core_infra.name}"
  address     = local.vault_addr
  token       = local.boundary_worker_ssh.token
  namespace   = local.vault_namespace
  scope_id    = boundary_scope.core_infra.id
}

resource "boundary_credential_library_vault" "eks_nodes" {
  name                = "vault-${boundary_scope.core_infra.name}-eks-ssh"
  description         = "Credential library for EKS node SSH"
  credential_store_id = boundary_credential_store_vault.eks_nodes.id
  path                = local.boundary_worker_ssh.path
  http_method         = "GET"
  credential_type     = "ssh_private_key"
}