module "boundary" {
  source            = "../boundary-deployment"
  vpc_id            = module.vpc.vpc_id
  vpc_cidr_block    = module.vpc.vpc_cidr_block
  public_subnet_ids = module.vpc.public_subnets
  name              = var.name
  private_ssh_key   = var.private_ssh_key
  client_cidr_block = var.client_cidr_block
}