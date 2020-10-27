output "auth_method_id" {
  value = boundary_auth_method.password.id
}

output "backend_team_password" {
  value     = random_password.backend_team.result
  sensitive = true
}

output "backend_target" {
  value = boundary_target.backend_servers_ssh.id
}