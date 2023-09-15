data "aws_security_group" "database" {
  tags = merge(local.tags, {
    Purpose = "database"
  })
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

resource "aws_db_instance" "database" {
  allocated_storage      = 10
  engine                 = "postgres"
  engine_version         = var.postgres_db_version
  instance_class         = var.db_instance_class
  db_name                = var.db_name
  identifier             = "${var.business_unit}-${var.db_name}"
  username               = random_pet.database.id
  password               = random_password.database.result
  db_subnet_group_name   = local.db_subnet_group_name
  vpc_security_group_ids = [data.aws_security_group.database.id]
  skip_final_snapshot    = true
  storage_encrypted      = true
  copy_tags_to_snapshot  = true

  tags = local.tags
}