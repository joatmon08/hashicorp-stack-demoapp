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
  value = module.hcp.hcp_consul_id
}

output "hcp_consul_private_address" {
  value = module.hcp.hcp_consul_private_endpoint
}

output "hcp_consul_public_address" {
  value = var.hcp_consul_public_endpoint ? trim(module.hcp.hcp_consul_public_endpoint, "/") : ""
}

output "hcp_vault_cluster" {
  value = module.hcp.hcp_vault_id
}

output "hcp_vault_private_address" {
  value = module.hcp.hcp_vault_private_endpoint
}

output "hcp_vault_public_address" {
  value = var.hcp_vault_public_endpoint ? trim(module.hcp.hcp_vault_public_endpoint, "/") : ""
}

output "kubernetes_endpoint" {
  value = data.aws_eks_cluster.cluster.endpoint
}

output "product_database_address" {
  value = aws_db_instance.products.address
}

output "product_database_username" {
  value = aws_db_instance.products.username
}

output "product_database_password" {
  value     = aws_db_instance.products.password
  sensitive = true
}