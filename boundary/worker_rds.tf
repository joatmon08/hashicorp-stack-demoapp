module "boundary_worker_rds" {
  source  = "joatmon08/boundary/aws//modules/hcp"
  version = "0.5.0"

  name                = "${local.name}-boundary-worker-rds"
  boundary_cluster_id = split(".", replace(local.url, "https://", "", ))[0]
  worker_tags         = [local.name, "rds", "ingress"]
  vpc_id              = local.vpc_id
  key_pair_name       = local.boundary_key_pair_name
  public_subnet_id    = local.public_subnets.0
  vault_addr          = local.vault_addr
  vault_namespace     = local.vault_namespace
  vault_token         = local.vault_token
  vault_path          = "boundary/worker"
}

resource "aws_security_group_rule" "allow_boundary_worker_to_database" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = module.boundary_worker_rds.security_group_id
  security_group_id        = local.rds_security_group_id
}

data "vault_kv_secret_v2" "boundary_worker_token_rds" {
  depends_on = [module.boundary_worker_rds, data.vault_kv_secrets_list_v2.boundary_worker_tokens]
  mount      = local.boundary_worker_mount
  name       = split(".", module.boundary_worker_rds.worker.private_dns).0
}

resource "boundary_worker" "rds" {
  depends_on                  = [module.boundary_worker_rds, data.vault_kv_secret_v2.boundary_worker_token_rds]
  scope_id                    = boundary_scope.products_infra.id
  name                        = data.vault_kv_secret_v2.boundary_worker_token_rds.name
  description                 = "self-managed worker ${data.vault_kv_secret_v2.boundary_worker_token_rds.name} for RDS in ${local.vpc_id}"
  worker_generated_auth_token = data.vault_kv_secret_v2.boundary_worker_token_rds.data.token
}