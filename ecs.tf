resource "aws_ecs_cluster" "ecs" {
  name = "${var.prefix}-cluster"
  setting {
    name  = "containerInsights"
    value = "disabled"
  }

  tags = var.tags
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name       = aws_ecs_cluster.ecs.name
  capacity_providers = [var.fargate_type]
  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = var.fargate_type
  }
}

resource "aws_cloudwatch_log_group" "logs" {
  name              = "${var.prefix}-logs"
  retention_in_days = 1

  tags = var.tags
}

resource "aws_ecs_task_definition" "taskdef" {
  family             = "${var.prefix}-taskdef"
  task_role_arn      = aws_iam_role.taskrole.arn
  execution_role_arn = aws_iam_role.executionrole.arn
  container_definitions = jsonencode([
    {
      name      = "n8n"
      image     = var.container_image
      essential = true
      portMappings = [
        {
          containerPort = 5678
          hostPort      = 5678
          protocol      = "tcp"
        }
      ]
      mountPoints = [
        {
          sourceVolume  = "persistent"
          containerPath = "/home/node/.n8n"
          readOnly      = false
        }
      ]
      environment = [
        {
          name  = "WEBHOOK_URL"
          value = var.url != null ? var.url : "${var.certificate_arn == null ? "http" : "https"}://${aws_lb.main.dns_name}/"
        },
        {
          name  = "N8N_SKIP_WEBHOOK_DEREGISTRATION_SHUTDOWN"
          value = "true"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.logs.name
          awslogs-region        = data.aws_region.current.id
          awslogs-stream-prefix = "n8n"
        }
      }
    }
  ])
  volume {
    name = "persistent"
    efs_volume_configuration {
      file_system_id          = aws_efs_file_system.main.id
      transit_encryption      = "ENABLED"
      transit_encryption_port = 2999
      authorization_config {
        access_point_id = aws_efs_access_point.access.id
        iam             = "ENABLED"
      }
    }
  }
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory

  tags = var.tags
}

resource "aws_security_group" "n8n" {
  name   = "${var.prefix}-sg"
  vpc_id = local.vpc_id
  ingress {
    from_port = 5678
    to_port   = 5678
    protocol  = "tcp"
    security_groups = [
      aws_security_group.alb.id
    ]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = var.tags
}

resource "aws_ecs_service" "service" {
  name            = "${var.prefix}-service"
  cluster         = aws_ecs_cluster.ecs.id
  task_definition = aws_ecs_task_definition.taskdef.arn
  desired_count   = var.desired_count
  capacity_provider_strategy {
    capacity_provider = var.fargate_type
    weight            = 100
    base              = 1
  }
  network_configuration {
    subnets = local.ecs_subnets
    security_groups = [
      aws_security_group.n8n.id
    ]
    # Only assign public IP when using public subnets
    # Private subnets should route through NAT Gateway for internet access
    assign_public_ip = !var.use_private_subnets && length(var.subnet_ids) == 0
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.ip.arn
    container_name   = "n8n"
    container_port   = 5678
  }

  tags = var.tags
}
