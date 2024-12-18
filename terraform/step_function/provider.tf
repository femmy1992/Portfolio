provider "aws" {
  region = "ca-central-1"
  alias  = "project"
  assume_role {
    role_arn = var.role_arn
  }
}

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}