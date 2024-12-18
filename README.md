# Portfolios

# Project 1 
Name: 
Automated Data Transfer & Security Pipeline with SFTP, AWS S3, SharePoint, and CodePipeline

Branch: 
automated-data-transfer

Summary: 
This project automates the data transfer workflow between an SFTP server, AWS S3, and SharePoint using AWS Lambda functions. The goal is to enable seamless file transfers across multiple platforms with built-in security and compliance scans. 
The project includes:
i. Terraform code for aws infrastructures
ii. Cloudformation code for aws codepipeline
iii. python code for lambda function


# Project 2
Name: 
Application Dashboard - Full-Stack AWS Deployment with GitLab CI/CD and Terraform

Branch: 
application-dashbaord

Summary: 
Developed and deployed an Application Dashboard, a full-stack web application used by financial advisors. 

The project features an automated GitLab CI/CD pipeline that manages the deployment of both the frontend and backend.

The frontend, built with Node.js, is deployed as a static website to Amazon S3 and served through AWS CloudFront with Web Application Firewall (WAF) protection for enhanced security. The backend, a containerized API, is built using Docker and deployed to AWS ECS (Elastic Container Service). 

All AWS infrastructure, including S3, ECS, CloudFront, WAF, and ECR, is provisioned using Terraform for infrastructure as code (IaC).

The pipeline handles different environments (staging, QA, and production) based on Git branch triggers, with automated linting, testing, building, and infrastructure updates. 

This solution ensures seamless, repeatable application delivery across all environments.

# Project 3

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
