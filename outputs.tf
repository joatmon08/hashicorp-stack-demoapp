resource "local_file" "vault_helm" {
  content = templatefile("templates/vault.tmpl", {
    vault_addr = var.hcp_vault_private_addr
  })
  filename = "${path.module}/vault.yml"
}

resource "local_file" "consul_helm" {
  content = templatefile("templates/consul.tmpl", {
    consul_host      = var.hcp_consul_host
    cluster_endpoint = module.eks.cluster_endpoint
  })
  filename = "${path.module}/consul.yml"
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "region" {
  value = var.region
}

output "eks_cluster_name" {
  value = var.name
}

output "boundary_endpoint" {
  value = "http://${module.boundary.boundary_lb}:9200"
}

output "boundary_kms_recovery_key_id" {
  value = module.boundary.kms_recovery_key_id
}