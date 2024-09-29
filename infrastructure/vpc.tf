################################################################################
# VPC Module
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.2"

  name = "${var.environment}"
  cidr = var.vpc_cidr

  azs             = var.availability_zones
  private_subnets = [cidrsubnet(var.vpc_cidr, 8, 1), cidrsubnet(var.vpc_cidr, 8, 2), cidrsubnet(var.vpc_cidr, 8, 3)]
  public_subnets  = [cidrsubnet(var.vpc_cidr, 8, 101), cidrsubnet(var.vpc_cidr, 8, 102), cidrsubnet(var.vpc_cidr, 8, 103)]

  create_redshift_subnet_group       = false
  create_redshift_subnet_route_table = true

  manage_default_security_group = true
  default_security_group_tags   = { Name = "${var.environment}-default" }

  enable_ipv6 = false

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  # VPC Flow Logs (Cloudwatch log group and IAM role will be created)
  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
  flow_log_max_aggregation_interval    = 60


  public_subnet_tags = {
    Name = "${var.environment}"
  }

  private_subnet_tags = {
    Name = "${var.environment}"
  }

  tags = {
    Owner = ""
  }

  vpc_tags = {
    Name        = "${var.environment}"
    Environment = var.vpc_environment_tag
  }
}

# VPC Endpoints and supporting resources

###############################################################################
# VPC Endpoints Sub-Module
###############################################################################

module "endpoints" {
  source = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"

  vpc_id             = module.vpc.vpc_id
  security_group_ids = [module.vpc.default_vpc_default_security_group_id]

  endpoints = {

    private_apigw = {
      # interface endpoint
      service             = "execute-api"
      subnet_ids          = module.vpc.private_subnets
      private_dns_enabled = true
      security_group_ids  = [aws_security_group.vpc_endpoints.id]
      tags                = { Name = "privateapi-vpc-endpoint-${var.environment}" }
    }
  }

  tags = {
    Owner       = ""
    Environment = "${var.environment}"
  }
}


resource "aws_security_group" "vpc_endpoints" {
  name        = "vpc-endpoints-sg-${var.environment}"
  description = "Allow access to VPC endpoints and interfaces"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "allow all access via SG rule (restrictions can be done on VPCE resource policy)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

