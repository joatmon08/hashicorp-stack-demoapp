variable "postgres_db_version" {
  type        = string
  default     = "13.11"
  description = "PostgreSQL version"
}

variable "db_instance_class" {
  type        = string
  default     = "db.t3.micro"
  description = "Database instance class"
}

variable "business_unit" {
  type        = string
  description = "Business unit. Also used as database subnet group"
}

variable "environment" {
  type        = string
  description = "Environment"
}

variable "db_name" {
  type        = string
  description = "Database name to create in instance"
}

variable "boundary_scope_id" {
  type        = string
  description = "Boundary scope ID for setting up target to database"
}

locals {
  tags = {
    Environment   = var.environment
    Automation    = "terraform"
    Business_Unit = var.business_unit
  }
  db_subnet_group_name = var.business_unit
}