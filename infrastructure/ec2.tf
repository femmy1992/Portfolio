# Application Load Balancer
resource "aws_alb" "main" {
  name            = "${var.environment}-lb"
  subnets         = module.vpc.public_subnets
  internal        = false
  security_groups = [aws_security_group.lb.id]
}

# Target Group
resource "aws_alb_target_group" "main" {
  name        = "${var.environment}-api-tg-${substr(uuid(), 0, 3)}"
  port        = var.app_port
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/health"
    unhealthy_threshold = "2"
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [name]
  }
}

# Listener
resource "aws_alb_listener" "main" {
  load_balancer_arn = aws_alb.main.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.main.id
    type             = "forward"
  }
}

# Load balancer security group
resource "aws_security_group" "lb" {
  name   = "${var.environment}-lb-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
