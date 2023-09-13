resource "consul_acl_policy" "terminating_gateway_database" {
  name  = "database-write-policy"
  rules = <<-RULE
service_prefix "database" {
    policy = "write"
}
    RULE
}