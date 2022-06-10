variable "signed_cert" {
  default     = false
  type        = bool
  description = "Has the certificate been signed yet?"
}

locals {
  seconds_in_1_hour  = 3600
  seconds_in_1_year  = 31536000
  seconds_in_3_years = 94608000
}

variable "trusted_domain" {
  default     = "2813c633-81ce-3a64-293b-3d1725f8b403.consul"
  description = "Get from http://127.0.0.1:8500/v1/connect/ca/roots"
  type        = string
}