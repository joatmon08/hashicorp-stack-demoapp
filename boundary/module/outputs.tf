output "auth_method_id" {
  value = boundary_auth_method.password.id
}

output "operations_team_password" {
  value     = random_password.operations_team.result
  sensitive = true
}

output "eks_nodes_target" {
  value = boundary_target.eks_nodes_ssh.id
}