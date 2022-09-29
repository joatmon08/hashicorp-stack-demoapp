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