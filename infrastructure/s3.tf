# Static site bucket
resource "aws_s3_bucket" "static_site" {
  bucket = "${var.environment}-static-site"
}

data "aws_iam_policy_document" "static_site_s3_policy" {
  statement {
    actions = ["s3:GetObject"]

    resources = [
      aws_s3_bucket.static_site.arn,
      "${aws_s3_bucket.static_site.arn}/*"
    ]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.oai.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "static_site_bucket_policy" {
  bucket = aws_s3_bucket.static_site.id
  policy = data.aws_iam_policy_document.static_site_s3_policy.json
}
