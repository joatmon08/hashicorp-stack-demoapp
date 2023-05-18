resource "hcp_vault_cluster" "main" {
  cluster_id      = var.name
  hvn_id          = hcp_hvn.main.hvn_id
  public_endpoint = var.hcp_vault_public_endpoint
  tier            = var.hcp_vault_tier

  metrics_config {
    datadog_api_key = var.datadog_api_key
    datadog_region  = var.datadog_region
  }

  audit_log_config {
    datadog_api_key = var.datadog_api_key
    datadog_region  = var.datadog_region
  }
}

resource "hcp_vault_cluster_admin_token" "cluster" {
  cluster_id = hcp_vault_cluster.main.cluster_id
}