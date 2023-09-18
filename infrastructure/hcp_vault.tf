data "http" "vault_version" {
  url = "https://api.releases.hashicorp.com/v1/releases/vault/latest"
}

resource "hcp_vault_cluster" "main" {
  cluster_id      = var.name
  hvn_id          = hcp_hvn.main.hvn_id
  public_endpoint = var.hcp_vault_public_endpoint
  tier            = var.hcp_vault_tier

  # metrics_config {
  #   datadog_api_key = var.datadog_api_key
  #   datadog_region  = var.datadog_region
  # }

  # audit_log_config {
  #   datadog_api_key = var.datadog_api_key
  #   datadog_region  = var.datadog_region
  # }

  lifecycle {
    postcondition {
      condition     = replace(self.vault_version, "v", "") != jsondecode(data.http.vault_version.response_body).version
      error_message = "Avoid using latest Vault version until approved"
    }
  }
}

resource "hcp_vault_cluster_admin_token" "cluster" {
  cluster_id = hcp_vault_cluster.main.cluster_id
}

check "hcp_vault_status" {
  data "http" "vault_health" {
    url = "${hcp_vault_cluster.main.vault_public_endpoint_url}/v1/sys/health"
  }

  assert {
    condition     = data.http.vault_health.status_code == 200 || data.http.vault_health.status_code == 473
    error_message = "${data.http.vault_health.url} returned an unhealthy status code"
  }
}