// Log Group
resource "aws_cloudwatch_log_group" "log_group" {
  name              = "awslogs-${var.environment}-api"
  retention_in_days = var.log_group_retention
}

// Log Stream
resource "aws_cloudwatch_log_stream" "log_stream" {
  name           = "${var.environment}-log-stream"
  log_group_name = aws_cloudwatch_log_group.log_group.name
}


// CloudFront Health Check
resource "aws_route53_health_check" "health_check" {
  provider          = aws.us_east_1
  fqdn              = aws_cloudfront_distribution.distribution.domain_name
  port              = 443
  type              = "HTTPS"
  resource_path     = "/"
  failure_threshold = "5"
  request_interval  = "30"

  tags = {
    Name = "${var.environment}-cloudfront-health-check"
  }
}

resource "aws_cloudwatch_metric_alarm" "metric_alarm" {
  provider                  = aws.us_east_1
  alarm_name                = "${var.environment}-alarm-cloudfront-health-check"
  comparison_operator       = "LessThanThreshold"
  evaluation_periods        = "1"
  metric_name               = "HealthCheckStatus"
  namespace                 = "AWS/Route53"
  period                    = "60"
  statistic                 = "Minimum"
  threshold                 = "1"
  insufficient_data_actions = []
  alarm_actions             = [aws_sns_topic.alarms_us_east_1.arn]
  alarm_description         = "CloudFront ${var.environment} health check"

  dimensions = {
    HealthCheckId = aws_route53_health_check.health_check.id
  }

  depends_on = [
    aws_sns_topic.alarms_us_east_1
  ]
}

// API Errors
resource "aws_cloudwatch_log_metric_filter" "api_error" {
  name           = "${var.environment}-api-errors"
  pattern        = "API_ERROR"
  log_group_name = aws_cloudwatch_log_group.log_group.name

  metric_transformation {
    name      = "${var.environment}-api-errors"
    namespace = "EventCount"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "api_error_alarm" {
  alarm_name          = "${var.environment}-api-error-alarm"
  metric_name         = aws_cloudwatch_log_metric_filter.api_error.name
  threshold           = "2"
  statistic           = "Sum"
  comparison_operator = "GreaterThanThreshold"
  datapoints_to_alarm = "1"
  evaluation_periods  = "1"
  period              = "600"
  namespace           = "EventCount"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]
}

// 4XX Errors
resource "aws_cloudwatch_log_metric_filter" "fourxx_error" {
  name           = "${var.environment}-4xx-errors"
  pattern        = "\"code: 4\""
  log_group_name = aws_cloudwatch_log_group.log_group.name

  metric_transformation {
    name      = "${var.environment}-4XX-errors"
    namespace = "EventCount"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "fourxx_error_alarm" {
  alarm_name          = "${var.environment}-4XX-error-alarm"
  metric_name         = aws_cloudwatch_log_metric_filter.fourxx_error.name
  threshold           = "5"
  statistic           = "Sum"
  comparison_operator = "GreaterThanThreshold"
  datapoints_to_alarm = "1"
  evaluation_periods  = "1"
  period              = "600"
  namespace           = "EventCount"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]
}

// ALB Health
resource "aws_cloudwatch_metric_alarm" "alb_healthyhosts" {
  alarm_name          = "${var.environment}-alb-healthyhosts"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "HealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Average"
  threshold           = var.ecs_desired_count
  alarm_description   = "Number of healthy nodes in the ${var.environment} target group."
  actions_enabled     = "true"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]
  dimensions = {
    TargetGroup  = aws_alb_target_group.main.arn_suffix
    LoadBalancer = aws_alb.main.arn_suffix
  }
}

// ECS CPU Usage
resource "aws_cloudwatch_metric_alarm" "ecs_cpu" {
  alarm_name          = "${var.environment}-ecs-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "CPU usage in the ${var.environment} ECS service."
  actions_enabled     = "true"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]
  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.main.name
  }
}

// ECS Memory Usage
resource "aws_cloudwatch_metric_alarm" "ecs_memory" {
  alarm_name          = "${var.environment}-ecs-memory"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Memory usage in the ${var.environment} ECS service."
  actions_enabled     = "true"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]
  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.main.name
  }
}

