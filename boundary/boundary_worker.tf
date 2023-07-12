resource "tls_private_key" "boundary" {
  algorithm = "RSA"
}

resource "aws_key_pair" "boundary" {
  key_name   = local.name
  public_key = trimspace(tls_private_key.boundary.public_key_openssh)
}

module "boundary_worker" {
  source  = "joatmon08/boundary/aws//modules/hcp"
  version = "0.4.0"

  name                = local.name
  boundary_cluster_id = split(".", replace(local.url, "https://", "", ))[0]
  worker_tags         = [local.name, "ingress"]
  vpc_id              = local.vpc_id
  key_pair_name       = aws_key_pair.boundary.key_name
  public_subnet_id    = local.public_subnets.0
  vault_addr          = local.vault_addr
  vault_namespace     = local.vault_namespace
  vault_token         = local.vault_token
  vault_path          = "boundary/worker"
}

resource "aws_security_group_rule" "allow_ssh_worker" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.client_cidr_block
  security_group_id = module.boundary_worker.security_group.id
}

resource "aws_security_group_rule" "allow_boundary_worker_to_eks" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = module.boundary_worker.security_group.id
  security_group_id        = local.eks_cluster_security_group_id
}

data "vault_kv_secrets_list_v2" "boundary_worker_tokens" {
  depends_on = [module.boundary_worker]
  mount      = local.boundary_worker_mount
}

data "vault_kv_secret_v2" "boundary_worker_token" {
  depends_on = [module.boundary_worker]
  for_each   = toset(nonsensitive(data.vault_kv_secrets_list_v2.boundary_worker_tokens.names))
  mount      = local.boundary_worker_mount
  name       = each.key
}

locals {
  boundary_worker_tokens = { for hostname, secret in data.vault_kv_secret_v2.boundary_worker_token : hostname => secret.data.token }
}

resource "boundary_worker" "worker_led" {
  depends_on                  = [module.boundary_worker]
  for_each                    = local.boundary_worker_tokens
  scope_id                    = "global"
  name                        = each.key
  description                 = "self-managed worker ${each.key} in ${local.vpc_id}"
  worker_generated_auth_token = each.value
}