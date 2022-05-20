module "eks" {
  depends_on      = [module.vpc]
  source          = "terraform-aws-modules/eks/aws"
  version         = "17.24.0"
  cluster_name    = var.name
  cluster_version = "1.22"
  subnets         = module.vpc.private_subnets

  vpc_id           = module.vpc.vpc_id
  write_kubeconfig = false

  node_groups_defaults = {
    ami_type  = "AL2_x86_64"
    disk_size = 50
  }

  node_groups = {
    hcp_consul = {
      desired_capacity = 3
      max_capacity     = 3
      min_capacity     = 3

      instance_types            = ["m5.large"]
      k8s_labels                = var.tags
      additional_tags           = var.additional_tags
      key_name                  = var.key_pair_name
      source_security_group_ids = [module.boundary.boundary_security_group]
    }
  }
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}