# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.environment}-cluster"
}

# Task Definition
resource "aws_ecs_task_definition" "main" {
  family                   = "${var.environment}-app-task"
  execution_role_arn       = aws_iam_role.execution_role.arn
  task_role_arn            = aws_iam_role.task_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.ecs_task_cpu
  memory                   = var.ecs_task_memory
  container_definitions = templatefile("container_definition.json.tpl", {
    name : "${var.environment}-api",
    aws_ecr_repository : aws_ecr_repository.main.repository_url
    cpu : var.ecs_task_cpu
    memory : var.ecs_task_memory
    app_port : var.app_port
    region : var.region
  })
  lifecycle {

      ignore_changes = all

    }
}

# ECS Service
resource "aws_ecs_service" "main" {
  name            = "${var.environment}-api-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn
  launch_type     = "FARGATE"
  desired_count   = var.ecs_desired_count

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id, module.vpc.default_vpc_default_security_group_id]
    subnets          = module.vpc.private_subnets
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.main.id
    container_name   = "${var.environment}-api"
    container_port   = var.app_port
  }

  depends_on = [aws_alb_listener.main]
}

# ECS Task Security Group
resource "aws_security_group" "ecs_tasks" {
  name   = "${var.environment}-ecs-tasks-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = var.app_port
    to_port         = var.app_port
    security_groups = [aws_security_group.lb.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
