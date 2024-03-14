terraform {
  required_version = "~> 1.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.27"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 4.0"
    }
    consul = {
      source  = "hashicorp/consul"
      version = "~> 2.20"
    }
    boundary = {
      source  = "hashicorp/boundary"
      version = "~> 1.1"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.40"
    }
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "~> 1.15"
    }
  }
}

provider "aws" {
  region = local.region
}

data "aws_eks_cluster" "cluster" {
  name = local.eks_cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = local.eks_cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "vault" {
  address   = local.vault_address
  token     = local.vault_token
  namespace = local.vault_namespace
}

provider "consul" {
  address    = local.consul_address
  token      = local.consul_token
  datacenter = local.consul_datacenter
}

provider "boundary" {
  addr                   = local.boundary_address
  auth_method_login_name = local.boundary_username
  auth_method_password   = local.boundary_password
}

provider "mongodbatlas" {
  public_key  = var.mongodbatlas_public_key
  private_key = var.mongodbatlas_private_key
}