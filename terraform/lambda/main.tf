################################################# lambda #############################################
# Lambda Layer resource
resource "aws_lambda_layer_version" "lambda_layer" {
  layer_name       = "python-dependencies-layer"
  compatible_runtimes = ["python3.11"] 
  compatible_architectures = ["x86_64"]
  s3_bucket = "bucket_name"
  s3_key = "lambda-layer/lambda_layer.zip"
}

# lambda function
resource "aws_lambda_function" "lambda" {
  for_each = var.lambda
  function_name = each.key
  filename         = data.archive_file.python_lambda_package[each.key].output_path
  source_code_hash = data.archive_file.python_lambda_package[each.key].output_base64sha256
  role    = data.aws_iam_role.lambda_role.arn
  runtime = each.value.runtime
  handler = each.value.handler
  timeout = each.value.timeout
  memory_size  = each.value.memory_size
  tags = {
    environment   = var.environment
    managed_by    = "terraform"
  }
  logging_config {
    log_format = "Text"
    log_group = aws_cloudwatch_log_group.log[each.key].name
  }
  vpc_config {
    subnet_ids         = data.aws_subnets.subnets.ids
    security_group_ids = [data.aws_security_group.sg.id]
  }

  layers = [
    aws_lambda_layer_version.lambda_layer.arn
  ]
  environment {
    variables = {
      SP_USERNAME = var.sp_username
      SP_SITE_URL = var.sp_site_url
      SFTP_HOST = var.sftp_host
      SFTP_USERNAME = var.sftp_username
      SFTP_DIRECTORY = var.sftp_directory
      S3_BUCKET_NAME = data.aws_s3_bucket.bucket.bucket
    }
  }
  
}

######################################## cloudwatch logs ###########################################
# logs
resource "aws_cloudwatch_log_group" "log" {
  for_each = var.lambda
  name = "/aws/lambda/${each.key}"
}

# alarms
resource "aws_cloudwatch_metric_alarm" "lambda_error_alarm" {
  for_each = var.lambda
  alarm_name          = "${each.key}-LambdaFunctionErrors"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "300" 
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "Triggers if there are any Lambda function errors."
  alarm_actions       = ["arn:aws:sns:ca-central-1:<account_number>:service-desk-notification"]

  dimensions = {
    FunctionName = aws_lambda_function.lambda[each.key].function_name
  }
}

##################################### eventbridge #############################################
# EventBridge Rule and permission for sftp-to-s3
resource "aws_cloudwatch_event_rule" "lambda_trigger" {
  name                = "sftp-to-s3-rule"
  schedule_expression = "cron(30 11,17,20 ? * 2-7 *)"  # Trigger at 7:30 AM, 1:30 PM, and 4:30 PM EST Mon - Sat
  description         = "Trigger Lambda function sftp-to-s3-lambda"
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.lambda_trigger.name
  target_id = "lambda-sftp-to-s3"
  arn       = aws_lambda_function.lambda["lambda-sftp-to-s3"].arn
}

resource "aws_lambda_permission" "allow_eventbridge_to_invoke_lambda" {
  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda["lambda-sftp-to-s3"].function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda_trigger.arn

}

############################## bucket notification ############################################
# notification and permission for s3-to-sharepoint
resource "aws_s3_bucket_notification" "s3_to_sharepoint_trigger" {
  bucket = data.aws_s3_bucket.bucket.bucket

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda["lambda-s3-to-sharepoint"].arn
    events              = ["s3:ObjectCreated:*"]
  }
}

resource "aws_lambda_permission" "allow_s3_to_invoke_lambda" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda["lambda-s3-to-sharepoint"].function_name
  principal     = "s3.amazonaws.com"
  source_arn = data.aws_s3_bucket.bucket.arn
}
