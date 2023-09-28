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

output "boundary" {
  value = {
    url      = local.url
    username = local.username
    password = local.password
  }
  sensitive = true
}

output "vault" {
  value = {
    address   = local.vault_addr
    namespace = local.vault_namespace
    token     = local.vault_admin_token
  }
  sensitive = true
}

output "boundary_worker_mount" {
  value = local.boundary_worker_mount
}

output "boundary_worker_eks" {
  value = {
    public_ip   = module.boundary_worker_eks.worker.public_ip
    private_dns = module.boundary_worker_eks.worker.private_dns
  }
}

## For applications to use

output "products_infra_scope_id" {
  value = boundary_scope.products_infra.id
}

output "boundary_worker_rds" {
  value = {
    public_ip   = module.boundary_worker_rds.worker.public_ip
    private_dns = module.boundary_worker_rds.worker.private_dns
  }
}