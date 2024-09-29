# API Repository
resource "aws_ecr_repository" "main" {
  name                 = "${var.environment}-api"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
