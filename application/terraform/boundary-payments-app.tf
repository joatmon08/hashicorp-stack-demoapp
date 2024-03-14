resource "boundary_target" "kubernetes" {
  type                     = "tcp"
  name                     = "kubernetes"
  description              = "Kubernetes API"
  scope_id                 = boundary_scope.apps["payments-app"].id
  ingress_worker_filter    = "\"eks\" in \"/tags/type\""
  egress_worker_filter     = "\"${local.name}\" in \"/tags/type\""
  address                  = replace(data.aws_eks_cluster.cluster.endpoint, "https://", "")
  session_connection_limit = -1
  default_port             = 443
  brokered_credential_source_ids = [
    boundary_credential_library_vault.application["payments-app"].id
  ]
}

resource "vault_policy" "token_basics" {
  name   = "token-basics"
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
EOT
}

resource "vault_token" "payments_processor" {
  policies          = [vault_policy.token_basics.name, vault_policy.payments_processor.name]
  no_default_policy = true
  no_parent         = true
  ttl               = "3d"
  explicit_max_ttl  = "6d"
  period            = "3d"
  renewable         = true
  num_uses          = 0
}

resource "boundary_credential_store_vault" "payments_processor" {
  name        = "payments-processor"
  description = "Vault credentials store for payments-processor"
  address     = local.vault_address
  token       = vault_token.payments_processor.client_token
  namespace   = local.vault_namespace
  scope_id    = boundary_scope.apps["payments-app"].id
}

resource "boundary_credential_library_vault" "payments_processor" {
  name                = "payments-processor"
  description         = "Credential library for payments-processor"
  credential_store_id = boundary_credential_store_vault.payments_processor.id
  path                = "payments-processor/static/data/creds"
  http_method         = "GET"
  credential_type     = "username_password"
}

data "kubernetes_service" "payments_processor" {
  count = var.deployed_payments_processor ? 1 : 0
  metadata {
    name      = "payments-processor"
    namespace = "payments-app"
  }
}

resource "boundary_target" "payments_processor" {
  count                    = var.deployed_payments_processor ? 1 : 0
  type                     = "tcp"
  name                     = "payments-processor"
  description              = "Payments processor API"
  scope_id                 = boundary_scope.apps["payments-app"].id
  ingress_worker_filter    = "\"eks\" in \"/tags/type\""
  egress_worker_filter     = "\"${local.name}\" in \"/tags/type\""
  address                  = try(data.kubernetes_service.payments_processor.0.status.0.load_balancer.0.ingress.0.hostname, "")
  session_connection_limit = -1
  default_port             = 8080
  brokered_credential_source_ids = [
    boundary_credential_library_vault.payments_processor.id
  ]
}