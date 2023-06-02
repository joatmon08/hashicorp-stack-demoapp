output "boundary_auth_method_id" {
  value = boundary_auth_method.password.id
}

output "boundary_operations_password" {
  value     = random_password.operations_team.result
  sensitive = true
}

output "boundary_products_password" {
  value     = random_password.products_team.result
  sensitive = true
}

output "boundary_target_eks" {
  value = boundary_target.eks_nodes_ssh.id
}

output "boundary_target_postgres" {
  value = boundary_target.products_database_postgres.id
}

output "boundary_target_frontend" {
  value = var.products_frontend_address != "" ? boundary_target.products_frontend.0.id : ""
}

output "boundary_endpoint" {
  value = local.url
}

output "boundary_worker" {
  value = module.boundary_worker.worker.public_ip
}