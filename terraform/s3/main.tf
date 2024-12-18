########################### sftp bucket ################################################
resource "aws_s3_bucket" "bucket" {
  bucket = "bucket-${data.aws_caller_identity.current.account_id}"

}

resource "aws_s3_bucket_policy" "policy" {
  bucket = aws_s3_bucket.bucket.id
  policy = data.aws_iam_policy_document.policy.json
}

resource "aws_s3_bucket_public_access_block" "block" {
    bucket = aws_s3_bucket.bucket.id
    block_public_acls = true
    block_public_policy = true
    ignore_public_acls = true
    restrict_public_buckets = true
}

# bucket versioning
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# bucket notification
resource "aws_s3_bucket_notification" "s3_to_eventbridge" {
  bucket = aws_s3_bucket.bucket.id
  eventbridge = true
}

# Define S3 bucket lifecycle configuration
resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    id     = "transition-to-glacier"
    status = "Enabled"

    # Apply rule to all objects in the bucket
    filter {
      prefix = "" # Applies to all objects
    }

    # Transition to GLACIER after 30 days
    transition {
      days          = 30
      storage_class = "GLACIER"
    }

    # Expire objects after 7 years (2555 days)
    expiration {
      days = 2555
    }
  }
}

