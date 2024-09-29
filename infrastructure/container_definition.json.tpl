[
  {
    "name": "${name}",
    "image": "${aws_ecr_repository}:latest",
    "essential": true,
    "cpu": ${cpu},
    "memory": ${memory},
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "${region}",
        "awslogs-stream-prefix": "${name}-service",
        "awslogs-group": "awslogs-${name}",
        "awslogs-multiline-pattern": "\\[\\d\\d\\d\\d-\\d\\d-\\d\\dT\\d\\d:\\d\\d:\\d\\d\\.\\d\\d\\dZ\\] - (DEBUG|INFO|LOG|WARN|ERROR):"
      }
    },
    "portMappings": [
      {
        "containerPort": ${app_port},
        "hostPort": ${app_port},
        "protocol": "tcp"
      }
    ],
    "environment": [],
    "secrets": []
  }
]
