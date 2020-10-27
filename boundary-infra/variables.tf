resource "random_pet" "test" {
  length = 1
}

locals {
  tags = {
    Name = "${var.tag}-${random_pet.test.id}"
  }
}

variable "tag" {
  default = "boundary-test"
}

variable "boundary_bin" {
  default = "~/projects/boundary/bin"
}

variable "pub_ssh_key_path" {
  default = "~/.ssh/id_rsa.pub"
}

variable "private_ssh_key_path" {
  default = "~/.ssh/id_rsa"
}

variable "num_workers" {
  default = 1
}

variable "num_controllers" {
  default = 2
}

variable "num_targets" {
  default = 1
}

variable "tls_cert_path" {
  default = "/etc/pki/tls/boundary/boundary.cert"
}

variable "tls_key_path" {
  default = "/etc/pki/tls/boundary/boundary.key"
}

variable "tls_disabled" {
  default = true
}

variable "kms_type" {
  default = "aws"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "List of Public Subnet IDs"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of Private Subnet IDs"
}