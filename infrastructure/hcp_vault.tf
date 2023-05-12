locals {
  datadog_config = (var.datadog_api_key != null && var.datadog_region != null) ? [{
    api_key = var.datadog_api_key
    region  = var.datadog_region
  }] : []
}

resource "hcp_vault_cluster" "main" {
  cluster_id      = var.name
  hvn_id          = hcp_hvn.main.hvn_id
  public_endpoint = var.hcp_vault_public_endpoint
  tier            = var.hcp_vault_tier

  dynamic "metrics_config" {
    for_each = local.datadog_config
    content {
      datadog_api_key = metrics_config.value.api_key
      datadog_region  = metrics_config.value.region
    }
  }

  dynamic "audit_log_config" {
    for_each = local.datadog_config
    content {
      datadog_api_key = audit_log_config.value.api_key
      datadog_region  = audit_log_config.value.region
    }
  }
}

resource "hcp_vault_cluster_admin_token" "cluster" {
  cluster_id = hcp_vault_cluster.main.cluster_id
}