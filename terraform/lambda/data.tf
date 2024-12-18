data "aws_caller_identity" "current" {}

data "aws_security_group" "sg" {
  filter {
    name = "tag:Name"
    values = ["security-group"]
  }
}

data "aws_iam_role" "lambda_role" {
  name = "lambda-role"
}

data "aws_subnets" "subnets" {
  filter {
    name   = "tag:Name"
    values = ["subnet1", "subnet2"]
  }
}

data "aws_s3_bucket" "bucket" {
  bucket = "bucket-${data.aws_caller_identity.current.account_id}"
}

data "aws_sfn_state_machine" "state" {
  name = "step-function"
}

data "archive_file" "python_lambda_package1" {
  type        = "zip"
  source_file= "./code/sftp_receiver_lambda/lambda_function.py"
  output_path = "${path.module}/lambda_function_sftp_receiver_lambda.zip"
}

data "archive_file" "python_lambda_package2" {
  type        = "zip"
  source_file= "./code/sftp_uploader_lambda/lambda_function.py"
  output_path = "${path.module}/lambda_function_sftp_uploader_lambda.zip"
}

data "archive_file" "python_lambda_package3" {
  type        = "zip"
  source_file= "./code/sharepoint_uploader_lambda/lambda_function.py"
  output_path = "${path.module}/lambda_function_sharepoint_uploader_lambda.zip"
}

data "archive_file" "lambda_dependencies_layer" {
  type        = "zip"
  source_dir  = "${path.module}/code/lambda_layer/"
  output_path = "${path.module}/code/lambda_layer.zip"
}

