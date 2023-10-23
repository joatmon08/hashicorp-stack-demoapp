resource "consul_acl_policy" "terminating_gateway_database" {
  name  = "database-write-policy"
  rules = <<-RULE
%{for team in keys(var.tfc_team_ids)}
service "${team}-database" {
    policy = "write"
}
%{endfor}
    RULE
}