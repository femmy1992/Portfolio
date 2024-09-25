resource "aws_security_group" "sg" {
  name        = "sg"
  description = "Security group for lambda function"
  vpc_id      = data.aws_vpc.vpc.id

  ingress {
    description      = "ingress rule"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"  
    self             = true
  }

  ingress {
    from_port = 0
    protocol = "tcp"
    to_port = 65535
    cidr_blocks = ["<vpc_cidr>"]
    description = "Allow traffic from edge vpc"
  }

  ingress {
    description      = "Allow traffic from vMX vpn"
    from_port        = 0
    to_port          = 65535
    protocol         = "tcp"  
    cidr_blocks      = ["<vpn_cidr>"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name = "sg"
  }
}