

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.16.0"

  cluster_name    = var.name
  cluster_version = "1.26"

  cluster_endpoint_public_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_group_defaults = {
    create_iam_role = true
    ami_type        = "AL2_x86_64"
    disk_size       = 100
    instance_types  = ["m5.large"]
  }

  eks_managed_node_groups = {
    hashicups = {
      use_custom_launch_template = false

      remote_access = {
        ec2_ssh_key               = aws_key_pair.boundary.key_name
        source_security_group_ids = [aws_security_group.boundary_worker.id]
      }

      min_size     = 1
      max_size     = 5
      desired_size = 3

      instance_types = ["m5.large"]
    }
  }
}

data "http" "kubernetes_version" {
  url = "https://api.github.com/repos/kubernetes/kubernetes/releases?per_page=1"

  request_headers = {
    Accept               = "application/vnd.github+json"
    X-GitHub-Api-Version = "2022-11-28"
  }

  lifecycle {
    postcondition {
      condition     = tonumber(module.eks.cluster_version) < tonumber(regex("[0-9]+.[0-9]+", jsondecode(self.response_body).0.tag_name))
      error_message = "Kubernetes cluster version should not be latest"
    }
  }
}

check "kubernetes_cluster_status" {
  data "aws_eks_cluster" "cluster" {
    name = module.eks.cluster_name
  }
  assert {
    condition     = data.aws_eks_cluster.cluster.status == "ACTIVE"
    error_message = "EKS cluster is not active"
  }
}