output "boundary_lb" {
  value = aws_lb.controller.dns_name
}

output "kms_recovery_key_id" {
  value = aws_kms_key.recovery.id
}

output "boundary_controller" {
  value = aws_instance.controller
}

output "boundary_key_name" {
  value = aws_key_pair.boundary.key_name
}

output "boundary_security_group" {
  value = aws_security_group.worker.id
}