module "boundary" {
  source               = "./boundary-infra"
  vpc_id               = module.vpc.vpc_id
  public_subnet_ids    = module.vpc.public_subnets
  private_subnet_ids   = module.vpc.private_subnets
  pub_ssh_key_path     = "~/projects/boundary/id_rsa.pub"
  private_ssh_key_path = "~/projects/boundary/id_rsa"
  num_targets          = 0
}