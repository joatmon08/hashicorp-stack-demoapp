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

    hcp = {
      source  = "hashicorp/hcp"
      version = "~> 0.29"
    }

    aws = {
      source  = "hashicorp/aws"
      version = ">=4.14,< 5.0"
    }

    consul = {
      source  = "hashicorp/consul"
      version = "~> 2.15"
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
  experiments {
    manifest_resource = true
  }
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

provider "hcp" {}

provider "vault" {
  address   = local.vault_public_addr
  namespace = local.vault_namespace
  token     = local.vault_token
}