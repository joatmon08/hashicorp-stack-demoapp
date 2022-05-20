resource "vault_mount" "consul_static" {
  path        = "consul/static"
  type        = "kv-v2"
  description = "KV Store for Consul static secrets"
}

resource "vault_generic_secret" "gossip" {
  path = "${vault_mount.consul_static.path}/gossip"

  data_json = <<EOT
{
  "key": "${var.consul_gossip_key}"
}
EOT
}

resource "vault_policy" "consul_gossip" {
  name = "consul-gossip"

  policy = <<EOT
path "${vault_mount.consul_static.path}/data/gossip" {
  capabilities = ["read"]
}
EOT
}

resource "random_uuid" "consul_bootstrap" {}

resource "vault_generic_secret" "bootstrap" {
  path = "${vault_mount.consul_static.path}/bootstrap"

  data_json = <<EOT
{
  "token": "${random_uuid.consul_bootstrap.result}"
}
EOT
}

resource "vault_policy" "consul_bootstrap" {
  name = "consul-bootstrap"

  policy = <<EOT
path "${vault_mount.consul_static.path}/data/bootstrap" {
  capabilities = ["read"]
}
EOT
}