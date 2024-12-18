data "aws_caller_identity" "current" {}

data "aws_iam_role" "sfn_role" {
  name = "sfn-role"
}

data "aws_lambda_function" "lambda1" {
  function_name = "sftp_uploader_lambda"
}

data "aws_lambda_function" "lambda2" {
  function_name = "sftp_receiver_lambda"
}

data "aws_lambda_function" "lambda3" {
  function_name = "sharepoint_uploader_lambda" 
}

data "aws_s3_bucket" "bucket" {
  bucket = "bucket-${data.aws_caller_identity.current.account_id}"
}

data "aws_cloudwatch_log_group" "log" {
  name = "/aws/sfn"
}