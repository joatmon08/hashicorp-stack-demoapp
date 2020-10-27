output "boundary_lb" {
  value = aws_lb.controller.dns_name
}

output "target_ips" {
  value = aws_instance.target.*.private_ip
}

output "kms_recovery_key_id" {
  value = aws_kms_key.recovery.id
}

output "boundary_key_pair" {
  value = aws_key_pair.boundary.key_name
}

output "boundary_security_groups" {
  value = [aws_security_group.worker.id]
}
