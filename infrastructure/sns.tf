resource "aws_sns_topic" "alarms" {
  name = "${var.environment}-alarms"
}

resource "aws_sns_topic_subscription" "email" {
  for_each  = toset(var.cloudwatch_alarm_email_addresses)
  topic_arn = aws_sns_topic.alarms.arn
  protocol  = "email"
  endpoint  = each.value
  depends_on = [
    aws_sns_topic.alarms
  ]
}


// US East 1 (Required for CloudFront health checks)
resource "aws_sns_topic" "alarms_us_east_1" {
  provider = aws.us_east_1
  name     = "${var.environment}-alarms-us-east-1"
}

resource "aws_sns_topic_subscription" "email_us_east_1" {
  provider  = aws.us_east_1
  for_each  = toset(var.cloudwatch_alarm_email_addresses)
  topic_arn = aws_sns_topic.alarms_us_east_1.arn
  protocol  = "email"
  endpoint  = each.value
  depends_on = [
    aws_sns_topic.alarms_us_east_1
  ]
}
