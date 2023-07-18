module "boundary_worker" {
  # source  = "joatmon08/boundary/aws//modules/hcp"
  # version = "0.4.0"
  source = "github.com/joatmon08/terraform-aws-boundary//modules/hcp"

  count = 1

  name                     = local.name
  boundary_cluster_id      = split(".", replace(local.url, "https://", "", ))[0]
  worker_tags              = [local.name, "ingress"]
  vpc_id                   = local.vpc_id
  key_pair_name            = local.boundary_key_pair_name
  public_subnet_id         = local.public_subnets.0
  vault_addr               = local.vault_addr
  vault_namespace          = local.vault_namespace
  vault_token              = local.vault_token
  vault_path               = "boundary/worker"
  worker_security_group_id = local.boundary_worker_security_group_id
}

resource "aws_security_group_rule" "allow_ssh_worker" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.client_cidr_block
  security_group_id = local.boundary_worker_security_group_id
}

resource "aws_security_group_rule" "allow_boundary_worker_to_eks" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = local.boundary_worker_security_group_id
  security_group_id        = local.eks_cluster_security_group_id
}

data "vault_kv_secrets_list_v2" "boundary_worker_tokens" {
  depends_on = [module.boundary_worker]
  mount      = local.boundary_worker_mount
}

data "vault_kv_secret_v2" "boundary_worker_token" {
  depends_on = [module.boundary_worker, data.vault_kv_secrets_list_v2.boundary_worker_tokens]
  count      = length(module.boundary_worker)
  mount      = local.boundary_worker_mount
  name       = split(".", module.boundary_worker[count.index].worker.private_dns).0
}

resource "boundary_worker" "worker_led" {
  depends_on                  = [module.boundary_worker, data.vault_kv_secret_v2.boundary_worker_token]
  count                       = length(module.boundary_worker)
  scope_id                    = "global"
  name                        = data.vault_kv_secret_v2.boundary_worker_token[count.index].name
  description                 = "self-managed worker ${data.vault_kv_secret_v2.boundary_worker_token[count.index].name} in ${local.vpc_id}"
  worker_generated_auth_token = data.vault_kv_secret_v2.boundary_worker_token[count.index].data.token
}