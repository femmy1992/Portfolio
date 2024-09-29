resource "aws_cloudfront_origin_access_identity" "oai" {}

data "aws_cloudfront_cache_policy" "static_site" {
  name = "Managed-CachingDisabled"
}

resource "aws_acm_certificate" "certificate" {
  count             = var.use_cloudfront_alias ? 1 : 0
  provider          = aws.us_east_1
  domain_name       = var.cloudfront_alias
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudfront_distribution" "distribution" {
  enabled             = true
  default_root_object = "index.html"
  is_ipv6_enabled     = true
  web_acl_id          = var.use_cloudflare_ip_whitelist ? aws_wafv2_web_acl.cloudfront[0].arn : null

  aliases = var.use_cloudfront_alias ? [var.cloudfront_alias] : null

  origin {
    domain_name = aws_s3_bucket.static_site.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.static_site.bucket_domain_name

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  origin {
    domain_name = aws_alb.main.dns_name
    origin_id   = aws_alb.main.dns_name

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.1"]
    }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = aws_s3_bucket.static_site.bucket_domain_name
    viewer_protocol_policy = "allow-all"
    cache_policy_id        = data.aws_cloudfront_cache_policy.static_site.id
  }


  ordered_cache_behavior {
    path_pattern           = "/api/*"
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD"]
    viewer_protocol_policy = "redirect-to-https"
    target_origin_id       = aws_alb.main.dns_name

    forwarded_values {
      query_string = true
      headers      = ["*"]
      cookies {
        forward = "all"
      }
    }
  }

  custom_error_response {
    error_caching_min_ttl = 60
    error_code            = 403
    response_code         = 403
    response_page_path    = "/index.html"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  dynamic "viewer_certificate" {
    for_each = var.use_cloudfront_alias ? [] : [1]
    content {
      cloudfront_default_certificate = true
    }
  }

  dynamic "viewer_certificate" {
    for_each = var.use_cloudfront_alias ? [1] : []
    content {
      acm_certificate_arn = aws_acm_certificate.certificate[0].arn
      ssl_support_method  = "sni-only"
    }
  }
}
