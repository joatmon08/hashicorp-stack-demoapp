variable "name" {
  type        = string
  description = "Name of the EKS cluster"
}

variable "region" {
  type        = string
  description = "AWS Region"
}

variable "hcp_region" {
  type        = string
  default     = ""
  description = "HCP Region"
}

variable "key_pair_name" {
  type        = string
  description = "SSH keypair name for Boundary and EKS nodes"
}

variable "vpc_cidr_block" {
  type        = string
  default     = "10.0.0.0/16"
  description = "CIDR Block for VPC"
}

variable "hcp_cidr_block" {
  type        = string
  default     = "172.25.16.0/20"
  description = "CIDR block of the HashiCorp Virtual Network"
}

variable "hcp_consul_datacenter" {
  type        = string
  default     = ""
  description = "HCP Consul datacenter name"
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
  type        = map(any)
  default     = {}
  description = "Tags to add resources"
}

variable "client_cidr_block" {
  type        = list(string)
  description = "Client CIDR block"
  sensitive   = true
}