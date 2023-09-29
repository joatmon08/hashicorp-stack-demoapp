resource "vault_mount" "transit" {
  path                      = "transit"
  type                      = "transit"
  description               = "Enable transit secrets backend"
  default_lease_ttl_seconds = 3600
  max_lease_ttl_seconds     = 86400
}