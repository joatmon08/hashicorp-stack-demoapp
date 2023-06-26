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

resource "random_password" "database_update" {
  length           = 16
  min_upper        = 2
  min_lower        = 2
  min_numeric      = 2
  min_special      = 2
  special          = true
  override_special = "`~!#$%^&*?"
}

resource "aws_db_instance" "products_update" {
  allocated_storage        = 20
  availability_zone        = "${var.region}c"
  db_name                  = null
  db_subnet_group_name     = module.vpc.database_subnet_group_name
  delete_automated_backups = true
  deletion_protection      = false
  engine                   = "postgres"
  engine_version           = "15.3"
  identifier               = "hashicups"
  instance_class           = "db.t3.micro"
  skip_final_snapshot      = true
  storage_encrypted        = true
  username                 = "postgres"
  password                 = random_password.database_update.result
  vpc_security_group_ids   = [aws_security_group.database.id]
}