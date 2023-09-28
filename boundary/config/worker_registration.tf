data "vault_kv_secrets_list_v2" "boundary_worker_tokens" {
  mount = local.boundary_worker_mount
}

data "vault_kv_secret_v2" "boundary_worker_token_eks" {
  depends_on = [data.vault_kv_secrets_list_v2.boundary_worker_tokens]
  mount      = local.boundary_worker_mount
  name       = split(".", local.boundary_worker_eks_dns).0
}

resource "boundary_worker" "eks" {
  depends_on                  = [data.vault_kv_secret_v2.boundary_worker_token_eks]
  scope_id                    = "global"
  name                        = data.vault_kv_secret_v2.boundary_worker_token_eks.name
  description                 = "self-managed worker ${data.vault_kv_secret_v2.boundary_worker_token_eks.name} for EKS"
  worker_generated_auth_token = data.vault_kv_secret_v2.boundary_worker_token_eks.data.token
}

data "vault_kv_secret_v2" "boundary_worker_token_rds" {
  depends_on = [data.vault_kv_secrets_list_v2.boundary_worker_tokens]
  mount      = local.boundary_worker_mount
  name       = split(".", local.boundary_worker_rds_dns).0
}

resource "boundary_worker" "rds" {
  scope_id                    = "global"
  name                        = data.vault_kv_secret_v2.boundary_worker_token_rds.name
  description                 = "self-managed worker ${data.vault_kv_secret_v2.boundary_worker_token_rds.name} for RDS"
  worker_generated_auth_token = data.vault_kv_secret_v2.boundary_worker_token_rds.data.token
}