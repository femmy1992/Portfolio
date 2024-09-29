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
