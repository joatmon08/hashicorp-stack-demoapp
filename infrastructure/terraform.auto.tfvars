region                     = "eu-west-1"
hcp_region                 = "eu-west-1"
name                       = "lynx"
hcp_consul_public_endpoint = true
hcp_vault_public_endpoint  = true

tags = {
  Environment = "hashicorp-stack-demoapp"
  Automation  = "terraform"
}