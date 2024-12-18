resource "aws_sfn_state_machine" "step_function" {
  name     = "step-function"
  role_arn = data.aws_iam_role.sfn_role.arn
  definition = jsonencode({
    Comment: "State machine for CanChek process with retries and error handling",
    StartAt: "GetSFTPCredentials",
    States: {
      "GetSFTPCredentials": {
        Type: "Task",
        Resource: "arn:aws:states:::aws-sdk:secretsmanager:getSecretValue",
        Parameters: {
          "SecretId": "sftp-private_key"
        },
        ResultPath: "$.SFTPCredentials",
        Next: "GetSharepointCredentials"
      },
      "GetSharepointCredentials": {
        Type: "Task",
        Resource: "arn:aws:states:::aws-sdk:secretsmanager:getSecretValue",
        Parameters: {
          "SecretId": "sharepoint/credential"
        },
        ResultPath: "$.SharepointCredentials",
        Next: "SFTPUpload"
      },
      "SFTPUpload": {
        Type: "Task",
        Resource: "${data.aws_lambda_function.lambda1.arn}",
        Parameters: {
          "SFTP_HOST": "${var.sftp_host}",          
          "SFTP_USERNAME": "${var.sftp_username}", 
          "SFTP_PRIVATE_KEY.$": "$.SFTPCredentials.SecretString",
          "SFTP_DIRECTORY_UPLOADER": "${var.sftp_directory_uploader}",          
          "S3_BUCKET_NAME": "${data.aws_s3_bucket.bucket.bucket}", 
          "S3_PREFIX": "${var.s3_prefix}"          
        },
        ResultPath: "$.SFTPUploadResult",
        Retry: [
          {
            ErrorEquals: ["Lambda.ServiceException", "Lambda.AWSLambdaException", "Lambda.SdkClientException"],
            IntervalSeconds: 30,
            MaxAttempts: 3,
            BackoffRate: 2.0
          }
        ],
        Catch: [
          {
            ErrorEquals: ["States.ALL"],
            Next: "FailState"
          }
        ],
        Next: "Wait30Minutes"
      },
      "Wait30Minutes": {
        Type: "Wait",
        Seconds: 1800,  # Wait for 30 minutes before continuing
        Next: "SFTPReceive"
      },
      "SFTPReceive": {
        Type: "Task",
        Resource: "${data.aws_lambda_function.lambda2.arn}",
        Parameters: {
          "SFTP_HOST": "${var.sftp_host}",          
          "SFTP_USERNAME": "${var.sftp_username}", 
          "SFTP_PRIVATE_KEY.$": "$.SFTPCredentials.SecretString", 
          "SFTP_DIRECTORY_RECEIVER": "${var.sftp_directory_receiver}",           
          "S3_BUCKET_NAME": "${data.aws_s3_bucket.bucket.bucket}",
          "RECEIVER_BUCKET_PREFIX": "${var.receiver_bucket_prefix}"           
        },
        ResultPath: "$.SFTPReceiveResult",
        Retry: [
          {
            ErrorEquals: ["Lambda.ServiceException", "Lambda.AWSLambdaException", "Lambda.SdkClientException"],
            IntervalSeconds: 30,
            MaxAttempts: 3,
            BackoffRate: 2.0
          }
        ],
        Catch: [
          {
            ErrorEquals: ["States.ALL"],
            Next: "FailState"
          }
        ],
        Next: "SharepointUpload"
      },
      "SharepointUpload": {
        Type: "Task",
        Resource: "${data.aws_lambda_function.lambda3.arn}",
        Parameters: {
          "SHAREPOINT_SITE_URL": "${var.sp_site_url}",
          "SHAREPOINT_USERNAME": "${var.sp_username}", 
          "SHAREPOINT_PASSWORD.$": "$.SharepointCredentials.SecretString", 
          "S3_BUCKET": "${data.aws_s3_bucket.bucket.bucket}",
          "SHAREPOINT_DOC": "${var.sp_doc}",
          "SHAREPOINT_SUBFOLDER": "${var.sp_subfolder}"
          "RECEIVER_BUCKET_PREFIX": "${var.receiver_bucket_prefix}"                   
        },
        ResultPath: "$.SharepointploadResult",
        Retry: [
          {
            ErrorEquals: ["Lambda.ServiceException", "Lambda.AWSLambdaException", "Lambda.SdkClientException"],
            IntervalSeconds: 30,
            MaxAttempts: 3,
            BackoffRate: 2.0
          }
        ],
        Catch: [
          {
            ErrorEquals: ["States.ALL"],
            Next: "FailState"
          }
        ],
        End: true
      },
      "FailState": {
        Type: "Fail",
        Error: "States.ALL",
        Cause: "State Machine Failed"
      }
    }
  })

  logging_configuration {
    log_destination        = "${data.aws_cloudwatch_log_group.log.arn}:*"
    include_execution_data = true
    level                  = "ALL"
  }
  
  tracing_configuration {
    enabled = true
  }
}

