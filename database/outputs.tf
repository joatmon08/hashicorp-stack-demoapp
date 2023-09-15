output "product_database_address" {
  value = aws_db_instance.database.address
}

output "database_static_path" {
  value       = vault_mount.static.path
  description = "Path to static secrets related to database service"
}

output "database_secret_name" {
  value       = local.database_secret_name
  description = "Name of secret with database admin credentials"
}

output "boundary_target_postgres" {
  value = boundary_target.database.id
}