resource "vault_mount" "payments_processor" {
  path        = "payments-processor/static"
  type        = "kv"
  options     = { version = "2" }
  description = "Static login for payments-processor"
}

resource "random_password" "payments_processor" {
  length           = 16
  min_upper        = 2
  min_lower        = 2
  min_numeric      = 2
  min_special      = 2
  special          = true
  override_special = "`~!#$%^&*?"
  keepers = {
    rotate_password = var.change_to_rotate_password
  }
}

resource "vault_kv_secret_v2" "payments_processor" {
  mount               = vault_mount.payments_processor.path
  name                = "creds"
  cas                 = 1
  delete_all_versions = true
  data_json = jsonencode(
    {
      username   = "payments-app"
      password   = random_password.payments_processor.result
      vault_addr = local.vault_private_address
    }
  )
}

resource "vault_policy" "payments_processor" {
  name = "payments-processor"

  policy = <<EOT
path "${vault_mount.payments_processor.path}/data/${vault_kv_secret_v2.payments_processor.name}" {
  capabilities = [ "read" ]
}
EOT
}

resource "vault_kubernetes_auth_backend_role" "payments_processor" {
  backend                          = local.vault_kubernetes_auth_path
  role_name                        = "payments-processor"
  bound_service_account_names      = ["payments-processor"]
  bound_service_account_namespaces = ["payments-app"]
  token_ttl                        = 86400
  token_policies = [
    vault_policy.payments_processor.name
  ]
}