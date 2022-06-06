## CTS-specific Vault policies and auth method
data "vault_policy_document" "cts" {
  rule {
    path         = "${vault_mount.static.path}/data/postgres"
    capabilities = ["read"]
    description  = "Allow CTS to access PostgreSQL database admin credentials"
  }

  rule {
    path         = "${vault_mount.static.path}/data/consul-terraform-sync"
    capabilities = ["read"]
    description  = "Allow CTS to access Consul token and Vault address"
  }

  rule {
    path         = "auth/token/create"
    capabilities = ["update"]
    description  = "Allow CTS to create child token for additional configuration"
  }

  rule {
    path         = "/sys/mounts"
    capabilities = ["read"]
    description  = "Allow CTS to get a list of secrets engines"
  }

  rule {
    path         = "/sys/mounts/${local.database_path}/*"
    capabilities = ["create", "read", "update", "delete", "list"]
    description  = "Allow CTS to manage mounts for databases"
  }

  rule {
    path         = "/${local.database_path}/${local.name}/*"
    capabilities = ["create", "read", "update", "delete", "list"]
    description  = "Allow CTS to set up database secrets engine at application database path"
  }

  rule {
    path         = "/sys/policies/acl/${local.name}"
    capabilities = ["create", "read", "update", "delete", "list"]
    description  = "Allow CTS to set up ACL policy for application"
  }

  rule {
    path         = "/auth/kubernetes/role/${local.name}"
    capabilities = ["create", "read", "update", "delete", "list"]
    description  = "Allow CTS to set up Kubernetes auth method for application"
  }
}

resource "vault_policy" "cts" {
  name   = "consul-terraform-sync"
  policy = data.vault_policy_document.cts.hcl
}

resource "vault_kubernetes_auth_backend_role" "consul_terraform_sync" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "consul-terraform-sync"
  bound_service_account_names      = ["consul-terraform-sync"]
  bound_service_account_namespaces = ["default"]
  token_ttl                        = 3600
  token_policies                   = [vault_policy.cts.name]
}