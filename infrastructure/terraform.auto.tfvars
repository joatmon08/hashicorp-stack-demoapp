region                     = "us-east-1"
hcp_region                 = "us-east-1"
datadog_region             = "us1"
key_pair_name              = "rosemary-us-east-1"
name                       = "hound"
hcp_consul_public_endpoint = true
hcp_vault_public_endpoint  = true

tags = {
  Environment = "hashicorp-stack-demoapp"
  Automation  = "terraform"
  Owner       = "rosemary"
}
