terraform {
  required_version = "~> 1.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.4"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.2"
    }
    hcp = {
      source  = "hashicorp/hcp"
      version = "~> 0.11"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.52"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 2.22"
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
  address   = data.hcp_vault_cluster.cluster.vault_public_endpoint_url
  token     = local.hcp_vault_cluster_token
  namespace = data.hcp_vault_cluster.cluster.namespace
}