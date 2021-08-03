region                     = "us-east-2"
name                       = "zero"
hcp_consul_public_endpoint = true
hcp_vault_public_endpoint  = true
tags = {
  Environment = "rosemary-zero-trust-demo"
  Automation  = "terraform"
  Owner       = "rosemary"
}