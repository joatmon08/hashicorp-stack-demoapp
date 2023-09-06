variable "signed_cert" {
  default     = false
  type        = bool
  description = "Has the certificate been signed yet?"
}

locals {
  seconds_in_20_minutes = 1200
  seconds_in_1_hour     = 3600
  seconds_in_1_year     = 31536000
  seconds_in_3_years    = 94608000
}

variable "cert_ou" {
  default     = "HashiConf"
  type        = string
  description = "Certificate organization unit"
}

variable "cert_organization" {
  default     = "HashiCorp"
  type        = string
  description = "Certificate organization"
}

variable "cert_country" {
  default     = "US"
  type        = string
  description = "Certificate country"
}

variable "cert_locality" {
  default     = "San Francisco"
  type        = string
  description = "Certificate locality (city)"
}

variable "cert_province" {
  default     = "California"
  type        = string
  description = "Certificate province (state)"
}