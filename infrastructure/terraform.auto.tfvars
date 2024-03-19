name                       = "hashicups"
hcp_consul_public_endpoint = true
hcp_vault_public_endpoint  = true

tags = {
  Environment   = "production"
  Automation    = "terraform"
  Business_Unit = "hashicups"
  Repo          = "hashicorp-stack-demoapp"
}