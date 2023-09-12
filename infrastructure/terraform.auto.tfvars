region         = "us-east-1"
hcp_region     = "us-east-1"
datadog_region = "us1"

name                       = "lynx"
hcp_consul_public_endpoint = true
hcp_vault_public_endpoint  = true

tags = {
  Environment   = "hashicorp-stack-demoapp"
  Automation    = "terraform"
  Business_Unit = "lynx"
}
