# Application Dashboard - Full-Stack AWS Deployment with GitLab CI/CD and Terraform

Developed and deployed an Application Dashboard, a full-stack web application used by financial advisors. 

The project features an automated GitLab CI/CD pipeline that manages the deployment of both the frontend and backend. 

The frontend, built with Node.js, is deployed as a static website to Amazon S3 and served through AWS CloudFront with Web Application Firewall (WAF) protection for enhanced security. The backend, a containerized API, is built using Docker and deployed to AWS ECS (Elastic Container Service). 

All AWS infrastructure, including S3, ECS, CloudFront, WAF, and ECR, is provisioned using Terraform for infrastructure as code (IaC).

The pipeline handles different environments (staging, QA, and production) based on Git branch triggers, with automated linting, testing, building, and infrastructure updates. 

This solution ensures seamless, repeatable application delivery across all environments.