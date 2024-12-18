This YAML script facilitates a fully automated pipeline workflow in AWS CodePipeline. It comprises the following stages:

    scan.yml: Static Code Analysis and Security Scans
        Used in the Scan Stage to ensure code quality and security compliance.
        Performs the following checks:
            SAST Scans: Identifies vulnerabilities in source code.
            OWASP Dependency Checks: Detects known vulnerabilities in dependencies.
            Secret Detection Scans: Ensures no sensitive information, such as API keys or credentials, is exposed.

    plan.yml: Infrastructure Planning
        Utilized in the Build Phase to generate Terraform plans.
        Outputs detailed Terraform execution plans to validate changes before deployment.
        Ensures infrastructure-as-code changes are reviewed and approved.

    apply.yml: Resource Deployment
        Used in the Deployment Phase to provision and manage cloud resources.
        Executes Terraform apply to deploy all infrastructure and application resources defined in Terraform configuration files.

This modular structure ensures a seamless and secure CI/CD process, focusing on code quality, infrastructure planning, and automated deployment.