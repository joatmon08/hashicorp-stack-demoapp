terraform {
  backend "remote" {
    organization = "hashicorp-stack-demoapp"

    workspaces {
      name = "vault-app"
    }
  }
}