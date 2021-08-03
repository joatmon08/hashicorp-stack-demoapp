variable "name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "region" {
  description = "AWS Region"
  type        = string
}

variable "private_ssh_key" {
  description = "Base64 encoded contents of private SSH key for Boundary and EKS nodes"
  type        = string
  sensitive   = true
}

variable "hcp_consul_datacenter" {
  default     = ""
  description = "HCP Consul datacenter name"
  type        = string
}

variable "hcp_consul_cidr_block" {
  type        = string
  default     = "172.25.16.0/20"
  description = "CIDR block of the HashiCorp Virtual Network"
}

variable "hcp_consul_public_endpoint" {
  type        = string
  default     = false
  description = "Enable HCP Consul public endpoint for cluster"
}

variable "hcp_vault_public_endpoint" {
  type        = string
  default     = false
  description = "Enable HCP Vault public endpoint for cluster"
}

variable "tags" {
  type        = map(any)
  description = "Tags to add resources"
}

variable "additional_tags" {
  default     = {}
  type        = map(any)
  description = "Tags to add resources"
}

variable "database_username" {
  default     = "postgres"
  type        = string
  description = "Username for postgresql"
}

variable "database_password" {
  type        = string
  description = "Password for postgresql"
  sensitive   = true
}

variable "client_cidr_block" {
  type        = string
  description = "Client CIDR block"
  sensitive   = true
}