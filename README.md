# Project Title:
Automated File Integration System Using AWS Lambda and Step Functions

# Project Introduction:
This project demonstrates the design and implementation of an automated file integration system using AWS Lambda, Step Functions, and Terraform. The solution includes three generic Lambda functions:

    S3 to SFTP Uploader: Uploads files from an S3 bucket to an SFTP server.
    SFTP to S3 Downloader: Retrieves files from an SFTP server and stores them in an S3 bucket.
    S3 to SharePoint Copier: Transfers files from an S3 bucket to a SharePoint site.

To orchestrate these functions, an AWS Step Function is utilized. The workflow begins by triggering the first Lambda function, waits for 30 minutes, and subsequently triggers the second and third Lambda functions in sequence. This architecture is designed for scalability and adaptability, allowing any third-party Step Function to invoke these generic Lambdas for their specific workflows.

The entire infrastructure, including the Lambda functions and Step Function, is provisioned using Terraform local modules that I developed, ensuring consistency, reusability, and simplified deployment processes.

This project showcases my expertise in serverless architecture, infrastructure as code (IaC), and seamless integration between diverse systems, reflecting best practices in DevOps and cloud-native design.