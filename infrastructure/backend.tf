terraform {
  backend "remote" {
    organization = "hashicorp-stack-demoapp-test"

    workspaces {
      name = "infrastructure"
    }
  }
}