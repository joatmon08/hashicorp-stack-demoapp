variable "postgres_hostname" {
  type        = string
  default     = ""
  description = "PostgreSQL hostname"
}

variable "kubernetes_host" {
  type        = string
  description = "Kubernetes host"
}

variable "kubernetes_ca_cert" {
  type        = string
  description = "Kubernetes CA certificates"
}

variable "postgres_port" {
  type        = number
  description = "PostgreSQL port"
  default     = 5432
}

variable "postgres_username" {
  type        = string
  description = "PostgreSQL username"
  default     = "postgres"
}

variable "postgres_password" {
  type        = string
  description = "PostgreSQL password"
  default     = "password"
}