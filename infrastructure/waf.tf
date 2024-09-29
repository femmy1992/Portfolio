resource "aws_wafv2_ip_set" "ipv4_whitelist" {
  count              = var.use_cloudflare_ip_whitelist ? 1 : 0
  name               = "cloudflare-ipv4-whitelist"
  provider           = aws.us_east_1
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"
  addresses = [
   
  ]
}

resource "aws_wafv2_ip_set" "ipv6_whitelist" {
  count              = var.use_cloudflare_ip_whitelist ? 1 : 0
  name               = "cloudflare-ipv6-whitelist"
  provider           = aws.us_east_1
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV6"
  addresses = [
   
  ]
}

resource "aws_wafv2_web_acl" "cloudfront" {
  count    = var.use_cloudflare_ip_whitelist ? 1 : 0
  name     = "${var.environment}-waf"
  provider = aws.us_east_1
  scope    = "CLOUDFRONT"

  default_action {
    block {}
  }

  rule {
    name     = "ipv4-whitelist"
    priority = 1

    action {
      allow {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.ipv4_whitelist[0].arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "WhitelistedIPV4"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "ipv6-whitelist"
    priority = 2

    action {
      allow {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.ipv6_whitelist[0].arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "WhitelistedIPV6"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "Blocked"
    sampled_requests_enabled   = true
  }
}
