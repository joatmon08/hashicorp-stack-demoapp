resource "aws_kms_key" "root" {
  description             = "Boundary root key"
  deletion_window_in_days = 10

  tags = {
    Name = "${var.name}-${random_pet.test.id}"
  }
}

resource "aws_kms_key" "worker_auth" {
  description             = "Boundary worker authentication key"
  deletion_window_in_days = 10

  tags = {
    Name = "${var.name}-${random_pet.test.id}"
  }
}

resource "aws_kms_key" "recovery" {
  description             = "Boundary recovery key"
  deletion_window_in_days = 10

  tags = {
    Name = "${var.name}-${random_pet.test.id}"
  }
}
