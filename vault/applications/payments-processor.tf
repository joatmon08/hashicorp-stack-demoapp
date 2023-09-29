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
}

resource "vault_kv_secret_v2" "payments_processor" {
  mount               = vault_mount.payments_processor.path
  name                = "creds"
  cas                 = 1
  delete_all_versions = true
  data_json = jsonencode(
    {
      password = random_password.payments_processor.result
    }
  )
}