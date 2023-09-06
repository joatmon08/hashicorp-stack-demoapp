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

output "boundary_leadership_password" {
  value     = random_password.leadership_team.result
  sensitive = true
}

output "boundary_target_eks" {
  value = boundary_target.eks_nodes_ssh.id
}

output "boundary_endpoint" {
  value = local.url
}

output "boundary_worker" {
  value = module.boundary_worker.0.worker.public_ip
}