resource "aws_ecr_repository" "frontend" {
  name = "frontend"

  image_scanning_configuration {
    scan_on_push = false
  }
}