variable "name" {
  type        = string
  description = "Name of the EKS cluster"
}

variable "region" {
  type        = string
  description = "AWS Region"

  validation {
    condition     = can(regex("^us-", var.region))
    error_message = "AWS Region must be in United States"
  }

}

variable "hcp_region" {
  type        = string
  default     = ""
  description = "HCP Region"
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

variable "hcp_consul_tier" {
  type        = string
  description = "HCP Consul Tier"
  default     = "standard"

  validation {
    condition = contains([
      "development", "standard", "plus"
    ], var.hcp_consul_tier)
    error_message = "Enter a valid HCP Consul tier. https://registry.terraform.io/providers/hashicorp/hcp/latest/docs/resources/consul_cluster#tier"
  }

}

variable "hcp_vault_public_endpoint" {
  type        = string
  default     = false
  description = "Enable HCP Vault public endpoint for cluster"
}

variable "hcp_vault_tier" {
  type        = string
  description = "HCP Vault Tier"
  default     = "standard_small"

  validation {
    condition = contains([
      "dev", "starter_small", "standard_small",
      "standard_medium", "standard_large",
      "plus_small", "plus_medium", "plus_large"
    ], var.hcp_vault_tier)
    error_message = "Enter a valid HCP Vault tier. https://registry.terraform.io/providers/hashicorp/hcp/latest/docs/resources/vault_cluster#tier"
  }

}

variable "hcp_boundary_tier" {
  type        = string
  description = "HCP Boundary Tier"
  default     = "Standard"

  validation {
    condition = contains([
      "Standard", "Plus"
    ], var.hcp_boundary_tier)
    error_message = "Enter a valid HCP Boundary tier. https://registry.terraform.io/providers/hashicorp/hcp/latest/docs/resources/boundary_cluster#tier"
  }

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
}

variable "datadog_api_key" {
  type        = string
  description = "API Key for Datadog"
  sensitive   = true
  default     = ""
}

variable "datadog_region" {
  type        = string
  description = "Region for Datadog"
  default     = ""
}

variable "argocd_github_app_private_key" {
  type        = string
  description = "Base64 encoded private key for Argo CD GitHub App"
  default     = null
  sensitive   = true
}