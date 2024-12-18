################################################# lambda #############################################
# Lambda Layer resource
resource "aws_lambda_layer_version" "lambda_layer" {
  layer_name       = "python-dependencies-layer"
  compatible_runtimes = ["python3.11"] 
  compatible_architectures = ["x86_64"]
  filename = data.archive_file.lambda_dependencies_layer.output_path
}

module "lambda_function1" {
  source                = "../lambda_function-module"
  function_name = "sftp_receiver_lambda"
  filename         = data.archive_file.python_lambda_package1.output_path
  source_code_hash = data.archive_file.python_lambda_package1.output_base64sha256
  role    = data.aws_iam_role.lambda_role.arn
  runtime = "python3.11"
  handler = "lambda_function.lambda_handler"
  timeout = 600
  memory_size  = 1024
  tags = {
    environment   = var.environment
    managed_by    = "terraform"
  }
  log_group = "/aws/lambda/sftp_receiver_lambda"

  subnet_ids         = data.aws_subnets.subnets.ids
  security_group_ids = [data.aws_security_group.sg.id]

  layers = [
    aws_lambda_layer_version.lambda_layer.arn
  ]

  permissions = [
    {
      statement_id = "AllowStepFunctionInvokeReceiver"
      action       = "lambda:InvokeFunction"
      principal    = "states.amazonaws.com"
      source_arn   = data.aws_sfn_state_machine.state.arn
    }
  ]
  
}

module "lambda_function2" {
  source                = "../lambda_function-module"
  function_name = "sftp_uploader_lambda"
  filename         = data.archive_file.python_lambda_package2.output_path
  source_code_hash = data.archive_file.python_lambda_package2.output_base64sha256
  role    = data.aws_iam_role.lambda_role.arn
  runtime = "python3.11"
  handler = "lambda_function.lambda_handler"
  timeout = 600
  memory_size  = 1024
  tags = {
    environment   = var.environment
    managed_by    = "terraform"
  }

  log_group = "/aws/lambda/sftp_uploader_lambda"
  
  subnet_ids         = data.aws_subnets.subnets.ids
  security_group_ids = [data.aws_security_group.sg.id]

  layers = [
    aws_lambda_layer_version.lambda_layer.arn
  ]

  permissions = [
    {
      statement_id = "AllowStepFunctionInvokeUploader"
      action       = "lambda:InvokeFunction"
      principal    = "states.amazonaws.com"
      source_arn   = data.aws_sfn_state_machine.state.arn
    }
  ]
  
}

module "lambda_function3" {
  source                = "../lambda_function-module"
  function_name = "sharepoint_uploader_lambda"
  filename         = data.archive_file.python_lambda_package3.output_path
  source_code_hash = data.archive_file.python_lambda_package3.output_base64sha256
  role    = data.aws_iam_role.lambda_role.arn
  runtime = "python3.11"
  handler = "lambda_function.lambda_handler"
  timeout = 600
  memory_size  = 1024
  tags = {
    environment   = var.environment
    managed_by    = "terraform"
  }

  log_group = "/aws/lambda/sharepoint_uploader_lambda"

  subnet_ids         = data.aws_subnets.subnets.ids
  security_group_ids = [data.aws_security_group.sg.id]

  layers = [
    aws_lambda_layer_version.lambda_layer.arn
  ]

  permissions = [
    {
      statement_id = "AllowStepFunctionInvokeSharepointUploader"
      action       = "lambda:InvokeFunction"
      principal    = "states.amazonaws.com"
      source_arn   = data.aws_sfn_state_machine.state.arn
    }
  ]
  
}