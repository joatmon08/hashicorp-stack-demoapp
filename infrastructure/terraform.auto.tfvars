region     = "us-east-1"
hcp_region = "us-east-1"
client_cidr_block = ["0.0.0.0/0"]

name                       = "lynx"
hcp_consul_public_endpoint = true
hcp_vault_public_endpoint  = true

tags = {
  Environment = "hashicorp-stack-demoapp"
  Automation  = "terraform"
}
