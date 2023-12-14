output "boundary_auth_method_id" {
  value = boundary_auth_method.password.id
}

output "boundary_operations_password" {
  value     = random_password.operations_team.result
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

output "boundary_org_id" {
  value = boundary_scope.org.id
}

output "boundary_password_auth_method_id" {
  value = boundary_auth_method.password.id
}