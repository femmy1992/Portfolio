data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lambda_policy" {
  statement {
    actions   = [
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:GetLogEvents",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
    effect    = "Allow"
    sid       = "cloudwatch"
  }
  statement {
    actions   = ["secretsmanager:GetSecretValue"]
    resources = ["arn:aws:secretsmanager:ca-central-1:${data.aws_caller_identity.current.account_id}:secret:sharepoint/credential"]
    effect    = "Allow"
    sid       = "secretmanager"
  }
  statement {
    actions   = ["ssm:GetParameter"]
    resources = ["arn:aws:ssm:ca-central-1:${data.aws_caller_identity.current.account_id}:parameter/sftp-private_key"]
    effect    = "Allow"
    sid       = "ssm"
  }
  statement {
    actions   = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:ListBucket",
      "s3:DeleteObject",
      "s3:PutObject",
      "s3:CopyObject",
      "s3:PutObjectAcl",
      "s3-object-lambda:Invoke", 
      "s3-object-lambda:WriteGetObjectResponse"
    ]
    resources = ["arn:aws:s3:::bucket-*"]
    effect    = "Allow"
    sid       = "s3"
  }
}

data "aws_iam_policy" "policy1" {
  name = "AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy" "policy2" {
  name = "AWSLambdaVPCAccessExecutionRole"
}
