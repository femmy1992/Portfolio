# S3 Bucket
resource "aws_s3_bucket" "bucket" {
  bucket = "devbkt2023"
  tags = {
    Name        = "${local.tag}-bkt"
    Environment = local.tag
  }
}

# # Static website configuration
# resource "aws_s3_bucket_website_configuration" "web" {
#   bucket = aws_s3_bucket.bucket.id

#   index_document {
#     suffix = "index.html"
#   }

#   error_document {
#     key = "error.html"
#   }
# }

# # Bucket Policy
# resource "aws_s3_bucket_policy" "pol" {
#   bucket = "${aws_s3_bucket.bucket.id}"
#   depends_on = [aws_s3_bucket.bucket]

#   policy = <<POLICY
# {
#   "Version": "2012-10-17",
#   "Id": "Policy1684974065080",
#   "Statement": [
#     {
#       "Sid": "Stmt1684974060112",
#       "Effect": "Allow",
#       "Principal": "*",
#       "Action": "*",
#       "Resource": "arn:aws:s3:::devbkt2023/*"
      
#     }
#   ]
# }
# POLICY
# }

# # BPA
# resource "aws_s3_bucket_public_access_block" "bpa" {
#   bucket = "${aws_s3_bucket.bucket.id}"

#   block_public_acls   = false
#   block_public_policy = false
# }

# # s3 bucket read/write permission
# resource "aws_s3_bucket_acl" "hosting" {
#     bucket = aws_s3_bucket.bucket.id
#     acl = "public-read"
  
# }

# # Upload Object
# resource "aws_s3_bucket_object" "obj" {
#   depends_on = [ aws_s3_bucket.bucket, aws_s3_bucket_policy.pol ]
#   bucket = "devbkt2023"
#   count = length(var.path)
#   key    = var.key[count.index]
#   source = var.path[count.index]

#   # The filemd5() function is available in Terraform 0.11.12 and later
#   # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
#   # etag = "${md5(file("path/to/file"))}"
#   etag = "${filemd5(var.path[count.index])}"
# }
