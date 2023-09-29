output "consul_tgw_database_policy" {
  value = consul_acl_policy.terminating_gateway_database.name
}