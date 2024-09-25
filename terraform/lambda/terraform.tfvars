lambda = {
    "lambda-sftp-to-s3" = {
        runtime = "python3.11"
        handler = "lambda_function.lambda_handler"
        timeout = 600
        memory_size  = 1024
        

    }
    "ilambda-s3-to-sharepoint" = {
        runtime = "python3.11"
        handler = "lambda_function.lambda_handler"
        timeout = 600
        memory_size  = 1024
    
    }
}

