resource "aws_security_group" "database" {
  name        = "${var.name}-database"
  description = "Allow inbound traffic to database"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Allow inbound from VPC"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  ingress {
    description = "Allow inbound from HCP Vault"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.hcp_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-database"
  }
}

resource "random_pet" "database" {
  length = 1
}

resource "random_password" "database" {
  length           = 16
  min_upper        = 2
  min_lower        = 2
  min_numeric      = 2
  min_special      = 2
  special          = true
  override_special = "`~!#$%^&*?"
}

resource "aws_db_instance" "products" {
  allocated_storage      = 10
  engine                 = "postgres"
  engine_version         = "14.7"
  instance_class         = "db.t3.micro"
  db_name                = "products"
  identifier             = "${var.name}-products"
  username               = random_pet.database.id
  password               = random_password.database.result
  db_subnet_group_name   = module.vpc.database_subnet_group_name
  vpc_security_group_ids = [aws_security_group.database.id]
  skip_final_snapshot    = true
  storage_encrypted      = true

  lifecycle {
    postcondition {
      condition     = self.storage_encrypted
      error_message = "encrypt AWS RDS database storage"
    }
  }

}

import {
  id = "products-v2"
  to = aws_db_instance.products_v2
}

resource "aws_db_instance" "products_v2" {
  allocated_storage                     = 20
  availability_zone                     = "${var.region}a"
  db_subnet_group_name                  = module.vpc.database_subnet_group_name
  delete_automated_backups              = true
  deletion_protection                   = false
  domain                                = null
  domain_iam_role_name                  = null
  enabled_cloudwatch_logs_exports       = []
  engine                                = "postgres"
  engine_version                        = "14.7"
  final_snapshot_identifier             = null
  iam_database_authentication_enabled   = false
  identifier                            = "products-v2"
  identifier_prefix                     = null
  instance_class                        = "db.t3.micro"
  iops                                  = 0
  license_model                         = "postgresql-license"
  maintenance_window                    = "thu:09:53-thu:10:23"
  manage_master_user_password           = null
  master_user_secret_kms_key_id         = null
  max_allocated_storage                 = 0
  monitoring_interval                   = 0
  monitoring_role_arn                   = null
  multi_az                              = false
  nchar_character_set_name              = null
  network_type                          = "IPV4"
  option_group_name                     = "default:postgres-14"
  parameter_group_name                  = "default.postgres14"
  password                              = null # sensitive
  performance_insights_enabled          = false
  performance_insights_kms_key_id       = null
  performance_insights_retention_period = 0
  port                                  = 5432
  publicly_accessible                   = false
  replica_mode                          = null
  replicate_source_db                   = null
  skip_final_snapshot                   = true
  snapshot_identifier                   = null
  storage_encrypted                     = true
  storage_throughput                    = 0
  storage_type                          = "gp2"
  tags                                  = {}
  tags_all                              = {}
  timezone                              = null
  username                              = "postgres"
  vpc_security_group_ids                = ["sg-0f0d10d09c631e6fa"]
}