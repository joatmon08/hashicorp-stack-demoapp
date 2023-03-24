resource "aws_key_pair" "boundary" {
  key_name   = var.name
  public_key = trimspace(tls_private_key.boundary.public_key_openssh)
}

resource "tls_private_key" "boundary" {
  algorithm = "RSA"
}