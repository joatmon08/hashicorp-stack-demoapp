terraform {
  required_version = "~> 1.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.13"
    }

    consul = {
      source  = "hashicorp/consul"
      version = "~> 2.16"
    }

    aws = {
      source  = "hashicorp/aws"
      version = ">=4.14,< 5.0"
    }

    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.8"
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

provider "consul" {
  address        = local.consul_addr
  scheme         = local.consul_scheme
  token          = local.consul_token
  insecure_https = local.consul_skip_tls_verify
}

provider "vault" {
  address   = local.vault_public_addr
  token     = local.vault_token
  namespace = local.vault_namespace
}