data "aws_vpc" "vpc" {
  filter {
    name = "tag:Name"
    values = [ "vpc-${var.env_prefix}" ]
  }
}
