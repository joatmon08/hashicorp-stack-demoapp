region                     = "us-west-2"
hcp_region                 = "us-west-2"
key_pair_name              = "rosemary-us-west-2"
name                       = "cat"
hcp_consul_public_endpoint = true
hcp_vault_public_endpoint  = true

tags = {
  Environment = "hashicorp-stack-demoapp"
  Automation  = "terraform"
  Owner       = "rosemary"
}
