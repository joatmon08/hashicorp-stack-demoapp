data "vault_policy_document" "application" {
  rule {
    path         = "*/static"
    capabilities = ["create", "update"]
    description  = "Allow applications to enable KVv2"
  }
  rule {
    path         = "database/*"
    capabilities = ["create", "update"]
    description  = "Allow applications to enable database secrets engines"
  }
}

resource "vault_policy" "application" {
  name   = "application"
  policy = data.vault_policy_document.application.hcl
}

resource "vault_token_auth_backend_role" "application" {
  role_name              = "application"
  allowed_policies       = [vault_policy.application.name]
  disallowed_policies    = ["default"]
  orphan                 = true
  token_period           = "86400"
  renewable              = true
  token_explicit_max_ttl = "115200"
}

resource "vault_token" "application" {
  role_name = vault_token_auth_backend_role.application.role_name
  policies  = [vault_policy.application.name]
}

resource "vault_mount" "terraform_cloud_operator" {
  path        = "tfc/operator"
  type        = "kv"
  options     = { version = "2" }
  description = "Terraform Cloud operator variables"
}

data "vault_policy_document" "terraform_cloud_operator" {
  rule {
    path         = "${vault_mount.terraform_cloud_operator.path}/*"
    capabilities = ["read"]
    description  = "Allow TFC operator to get secrets for workspace"
  }
}

resource "vault_policy" "terraform_cloud_operator" {
  name   = "terraform-cloud-operator"
  policy = data.vault_policy_document.terraform_cloud_operator.hcl
}

resource "vault_kubernetes_auth_backend_role" "terraform_cloud_operator" {
  backend                          = local.vault_kubernetes_auth_path
  role_name                        = "terraform-cloud-operator"
  bound_service_account_names      = ["tfc-controller-manager"]
  bound_service_account_namespaces = ["terraform-cloud-operator"]
  token_ttl                        = 86400
  token_policies = [
    vault_policy.terraform_cloud_operator.name
  ]
}

resource "vault_kv_secret_v2" "terraform_cloud_operator_workspace_secrets" {
  mount               = vault_mount.terraform_cloud_operator.path
  name                = "terraform-aws-postgres"
  delete_all_versions = true

  data_json = <<EOT
{
  "boundary_address": "${local.boundary_address}",
  "boundary_username": "${local.boundary_username}",
  "boundary_password": "${local.boundary_password}",
  "consul_address": "${local.consul_address}",
  "consul_token" : "${local.consul_token}",
  "consul_datacenter": "${local.consul_datacenter}",
  "vault_address": "${local.vault_address}",
  "vault_token": "${vault_token.application.client_token}",
  "vault_namespace": "${local.vault_namespace}"
}
EOT
}