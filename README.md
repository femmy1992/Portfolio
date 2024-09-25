# Automated Data Transfer & Security Pipeline with SFTP, AWS S3, SharePoint, and CodePipeline

This project automates the data transfer workflow between an SFTP server, AWS S3, and SharePoint using AWS Lambda functions. The goal is to enable seamless file transfers across multiple platforms with built-in security and compliance scans. The project includes two Lambda functions:

1. SFTP to S3 Data Transfer: Automatically pulls files from an SFTP server, uploads them to an S3 bucket, and removes the files from the SFTP server.

2. S3 to SharePoint File Sync: Syncs files from the S3 bucket to a specified folder in SharePoint, ensuring data accessibility and organization.

The project also includes a cloudformation code for robust CI/CD pipeline set up using AWS CodePipeline. The pipeline performs multiple stages of testing and security scanning to maintain the integrity of the project, including:

1. SonarQube for code quality checks and bug detection.

2. OWASP Dependency Check for vulnerability scanning in third-party libraries.

3. Secret Detection to identify and handle any sensitive information before deployment.

These security scans and tests run in the staging environment pipeline as a part of the project’s compliance to modern security standards.

# Key Features:

1. Seamless file transfers between SFTP, S3, and SharePoint using Python Lambda functions.
2. Secure and automated CI/CD pipeline utilizing AWS services.
3. Code and dependency vulnerability checks using SonarQube, OWASP Dependency Check, and Secret Detection.
4. This project showcases an end-to-end automation solution with integrated security best practices, making it a great   fit for businesses needing automated file management workflows with robust security and compliance checks.