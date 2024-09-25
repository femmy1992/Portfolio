# iam roles
resource "aws_iam_role" "lambda_role" {
  name               = "lambda-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

# iam policy
resource "aws_iam_policy" "lambda_policy" {
  name = "lambda-policy"
  path = "/"
  policy = data.aws_iam_policy_document.lambda_policy.json
}

# policy attachments
resource "aws_iam_role_policy_attachment" "attach_lambda" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_lambda1" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = data.aws_iam_policy.policy1.arn
}

resource "aws_iam_role_policy_attachment" "attach_lambda2" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = data.aws_iam_policy.policy2.arn
}