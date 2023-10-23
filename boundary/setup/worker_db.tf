module "boundary_worker_database" {
  source  = "joatmon08/boundary/aws//modules/hcp"
  version = "0.5.1"

  name                = "${local.name}-boundary-worker-database"
  boundary_cluster_id = split(".", replace(local.url, "https://", "", ))[0]
  worker_tags         = [local.name, "database", "ingress"]
  vpc_id              = local.vpc_id
  key_pair_name       = local.boundary_key_pair_name
  public_subnet_id    = local.public_subnets.0
  vault_addr          = local.vault_addr
  vault_namespace     = local.vault_namespace
  vault_token         = local.vault_worker_token
  vault_path          = "boundary/worker"
}