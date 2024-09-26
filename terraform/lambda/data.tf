data "aws_caller_identity" "current" {}

data "aws_security_group" "sg" {
  name = "sg"
}

data "aws_iam_role" "lambda_role" {
  name = "lambda-role"
}

data "aws_subnets" "subnets" {
  filter {
    name   = "tag:Name"
    values = ["snet-${var.env_prefix}-web-ca-central-1a", "snet-${var.env_prefix}-web-ca-central-1b"]
  }
}

data "aws_s3_bucket" "bucket" {
  bucket = "bucket-${data.aws_caller_identity.current.account_id}"
}

data "archive_file" "python_lambda_package" {
  for_each = var.lambda
  type        = "zip"
  source_file= "./code/${each.key}/lambda_function.py"
  output_path = "${path.module}/lambda_function_${each.key}.zip"
}

