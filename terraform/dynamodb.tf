resource "aws_dynamodb_table" "dynamodb" {
  name           = "${local.tag}-db"
  hash_key       = "ID"
  read_capacity  = 20
  write_capacity = 20
  attribute {
    name = "ID"
    type = "S"
  }
  tags = {
    Name        = "${local.tag}-db"
    Environment = local.tag
  }
}