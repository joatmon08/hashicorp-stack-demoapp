# data "aws_security_group" "database" {
#   tags = {
#     Business_Unit = local.name
#     Purpose       = "database"
#   }
# }

# module "boundary_worker_rds" {
#   source  = "joatmon08/boundary/aws//modules/hcp"
#   version = "0.5.1"

#   name                = "${local.name}-boundary-worker-rds"
#   boundary_cluster_id = split(".", replace(local.url, "https://", "", ))[0]
#   worker_tags         = [local.name, "rds", "ingress"]
#   vpc_id              = local.vpc_id
#   key_pair_name       = local.boundary_key_pair_name
#   public_subnet_id    = local.public_subnets.0
#   vault_addr          = local.vault_addr
#   vault_namespace     = local.vault_namespace
#   vault_token         = local.vault_worker_token
#   vault_path          = "boundary/worker"
# }

# resource "aws_security_group_rule" "allow_boundary_worker_to_database" {
#   type                     = "ingress"
#   from_port                = 5432
#   to_port                  = 5432
#   protocol                 = "tcp"
#   source_security_group_id = module.boundary_worker_rds.security_group_id
#   security_group_id        = data.aws_security_group.database.id
# }