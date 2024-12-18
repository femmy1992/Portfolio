# logs
module "cloudwatch_log-group" {
  for_each = toset(var.lambda)
  source  = "terraform-aws-modules/cloudwatch/aws//modules/log-group"
  version = "~> 3.0"
  name = "/aws/lambda/${each.value}"
}

# alarms
module "cloudwatch_metric-alarm" {
  for_each = toset(var.lambda)
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "~> 3.0"
  alarm_name          = "${each.value}-LambdaFunctionErrors"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "300" 
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "Triggers if there are any Lambda function errors."
  alarm_actions       = ["arn:aws:sns:ca-central-1:337558950667:service-desk-notification"]

  dimensions = {
    FunctionName = data.aws_lambda_function.lambda[each.key].function_name
  }
  
}

# logs
module "cloudwatch_log-group" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/log-group"
  version = "~> 3.0"
  name = "/aws/sfn"

}

# eventbridge
resource "aws_cloudwatch_event_rule" "sfn_trigger" {
  name = "sfn-trigger"
  description = "Trigger step function"
  
  event_pattern = jsonencode({
    "source": ["aws.s3"],
    "detail-type": ["Object Created"],
    "detail": {
      "bucket": {
        "name": ["${data.aws_s3_bucket.bucket.bucket}"]
      },
      "object": {
        "key": [{
          "prefix": "requests/"
        }]
      }
    }
  })
}


resource "aws_cloudwatch_event_target" "sfn_target" {
  rule      = aws_cloudwatch_event_rule.sfn_trigger.name
  target_id = "sfn-target"
  arn       = data.aws_sfn_state_machine.sfn.arn
  role_arn = data.aws_iam_role.role.arn
}

