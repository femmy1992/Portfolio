# Terraform Cloud Config

terraform {
  required_version = ">= 0.12.2"

  backend "s3" {
    key = "terraform.tfstate"
  }


    required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Providers
provider "aws" {
  region = "ca-central-1"
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}
