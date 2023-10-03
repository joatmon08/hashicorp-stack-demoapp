resource "vault_kubernetes_secret_backend_role" "boundary" {
  backend                       = local.vault_kubernetes_secrets_engine_path
  name                          = local.boundary_cluster_role
  allowed_kubernetes_namespaces = keys(var.tfc_team_ids)
  token_max_ttl                 = 7200
  token_default_ttl             = 3600
  generated_role_rules          = <<EOT
{"rules":[{"apiGroups":[""],"resources":["pods","services"],"verbs":["get","list"]},{"apiGroups":[""],"resources":["pods/portforward", "services/portforward"],"verbs":["get","create"]}]}
EOT
}

resource "vault_policy" "boundary_controller" {
  name   = "boundary-controller"
  policy = <<EOT
path "auth/token/lookup-self" {
  capabilities = ["read"]
}

path "auth/token/renew-self" {
  capabilities = ["update"]
}

path "auth/token/revoke-self" {
  capabilities = ["update"]
}

path "sys/leases/renew" {
  capabilities = ["update"]
}

path "sys/leases/revoke" {
  capabilities = ["update"]
}

path "sys/capabilities-self" {
  capabilities = ["update"]
}

path "${local.vault_kubernetes_secrets_engine_path}/creds/${vault_kubernetes_secret_backend_role.boundary.name}" {
  capabilities = ["update"]
}
EOT
}

resource "vault_policy" "database" {
  for_each = toset(keys(var.tfc_team_ids))
  name     = "database-${each.value}"
  policy   = <<EOT
path "${each.value}/static/data/*" {
  capabilities = ["read"]
}
EOT
}

resource "vault_token" "boundary_controller" {
  for_each          = toset(keys(var.tfc_team_ids))
  policies          = [vault_policy.boundary_controller.name, vault_policy.database[each.value].id]
  no_default_policy = true
  no_parent         = true
  ttl               = "3d"
  explicit_max_ttl  = "6d"
  period            = "3d"
  renewable         = true
  num_uses          = 0
}

resource "boundary_credential_store_vault" "application" {
  for_each    = toset(keys(var.tfc_team_ids))
  name        = "vault-${each.value}"
  description = "Vault credentials store for ${each.value}"
  address     = local.vault_address
  token       = vault_token.boundary_controller[each.value].client_token
  namespace   = local.vault_namespace
  scope_id    = boundary_scope.apps[each.value].id
}

resource "boundary_credential_library_vault" "application" {
  for_each            = toset(keys(var.tfc_team_ids))
  name                = "vault-kubernetes-${each.value}"
  description         = "Credential library for ${each.value} application debugging"
  credential_store_id = boundary_credential_store_vault.application[each.value].id
  path                = "${local.vault_kubernetes_secrets_engine_path}/creds/${vault_kubernetes_secret_backend_role.boundary.name}"
  http_request_body   = <<EOT
{\"kubernetes_namespace\": \"${each.value}\"}
EOT
  http_method         = "POST"
}