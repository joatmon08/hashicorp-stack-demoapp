terraform {
  required_version = "~> 1.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.11"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.5"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.14"
    }

    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.6"
    }
  }
}

provider "aws" {
  region = var.region == "" ? data.terraform_remote_state.infrastructure.outputs.region : var.region
}

data "aws_eks_cluster" "cluster" {
  name = var.aws_eks_cluster_id == "" ? data.terraform_remote_state.infrastructure.outputs.eks_cluster_id : var.aws_eks_cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.aws_eks_cluster_id == "" ? data.terraform_remote_state.infrastructure.outputs.eks_cluster_id : var.aws_eks_cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

provider "vault" {
  address   = local.hcp_vault_public_address
  token     = local.hcp_vault_cluster_token
  namespace = local.hcp_vault_namespace
}