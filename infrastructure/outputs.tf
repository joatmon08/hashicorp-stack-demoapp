output "vpc_id" {
  value = module.vpc.vpc_id
}

output "region" {
  value = var.region
}

output "eks_cluster_name" {
  value = var.name
}

output "eks_cluster_id" {
  value = module.eks.cluster_id
}

output "boundary_endpoint" {
  value = "http://${module.boundary.boundary_lb}:9200"
}

output "boundary_kms_recovery_key_id" {
  value = module.boundary.kms_recovery_key_id
}

output "hcp_consul_cluster" {
  value = hcp_consul_cluster.consul.cluster_id
}

output "kubernetes_endpoint" {
  value = data.aws_eks_cluster.cluster.endpoint
}

output "product_database_address" {
  value = aws_db_instance.products.address
}