resource "vault_policy" "module" {
  for_each = toset(keys(var.tfc_team_ids))
  name     = "create-secrets-engine-${each.value}"
  policy   = <<EOT
path "auth/token/create" {
  capabilities = [ "update" ]
}

path "auth/token/renew-self" {
  capabilities = [ "update" ]
}

path "auth/token/lookup-self" {
  capabilities = [ "read" ]
}

path "/sys/mounts" {
  capabilities = [ "read" ]
}

path "/sys/mounts/${each.value}/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "/${each.value}/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "/sys/policies/acl/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "/auth/kubernetes/role/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "/transit/keys/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
EOT
}

resource "vault_token_auth_backend_role" "module" {
  for_each               = toset(keys(var.tfc_team_ids))
  role_name              = each.value
  allowed_policies       = [vault_policy.module[each.value].name]
  disallowed_policies    = ["default"]
  orphan                 = true
  token_period           = "86400"
  renewable              = true
  token_explicit_max_ttl = "115200"
}

resource "vault_token" "module" {
  for_each  = toset(keys(var.tfc_team_ids))
  role_name = vault_token_auth_backend_role.module[each.value].role_name
  policies  = [vault_policy.module[each.value].name]
}

resource "vault_mount" "tfc_operator_vars" {
  for_each    = toset(keys(var.tfc_team_ids))
  path        = "terraform-cloud-operator/${each.value}"
  type        = "kv"
  options     = { version = "2" }
  description = "Variables for TFC modules run by the ${each.value} team"
}

resource "vault_kv_secret_v2" "postgres_module" {
  for_each            = toset(keys(var.tfc_team_ids))
  mount               = vault_mount.tfc_operator_vars[each.value].path
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
  "vault_token": "${vault_token.module[each.value].client_token}",
  "vault_namespace": "${local.vault_namespace}",
  "mongodbatlas_project_id": "${var.mongodbatlas_project_id}",
  "mongodbatlas_region": "${var.mongodbatlas_region}"
}
EOT
}