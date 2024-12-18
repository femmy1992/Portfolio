data "aws_lambda_function" "lambda" {
  for_each = toset(var.lambda)
  function_name = each.value
}

data "aws_caller_identity" "current" {}

data "aws_s3_bucket" "bucket" {
  bucket = "bucket-${data.aws_caller_identity.current.account_id}"
}

data "aws_iam_role" "role" {
  name = "eventbridge-role"
}

data "aws_sfn_state_machine" "sfn" {
  name = "step-function"
}