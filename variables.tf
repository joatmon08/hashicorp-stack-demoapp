variable "hcp_consul_host" {
  description = "HCP Consul Host for retry_join parameter"
  type        = string
}

variable "hcp_vault_private_addr" {
  description = "HCP Vault private IP address"
  type        = string
}

variable "name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "region" {
  default     = "us-west-2"
  description = "AWS Region"
  type        = string
}

variable "hcp_consul_cidr_block" {
  default     = "172.25.16.0/20"
  description = "CIDR Block for HCP Consul"
  type        = string
}

variable "peering_connection_has_been_added_to_hvn" {
  default     = false
  type        = bool
  description = "HVN Peering Connection pending confirmatin"
}

variable "tags" {
  default = {
    Environment = "around-the-hashistack"
  }
  type        = map
  description = "Tags to add resources"
}

variable "additional_tags" {
  default     = {}
  type        = map
  description = "Tags to add resources"
}