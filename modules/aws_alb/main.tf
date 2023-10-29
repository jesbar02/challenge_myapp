locals {
  required_tags = {
    Name        = "${var.project}-${terraform.workspace}",
    environment = terraform.workspace
  }
  tags = merge(var.resource_tags, local.required_tags)
}

locals {
  name_suffix = "${var.project}-${terraform.workspace}"
}


resource "aws_alb_target_group" "my_tg" {
  name                 = "${local.name_suffix}-tg"
  target_type          = "instance"
  port                 = 80
  protocol             = "HTTP"
  deregistration_delay = 15
  vpc_id               = var.vpc_id

  # health_check {
  #   path                = var.ecs_service_target_group_path
  #   matcher             = var.ecs_service_target_group_status
  #   timeout             = var.ecs_service_target_group_timeout
  #   interval            = var.ecs_service_target_group_interval
  #   healthy_threshold   = var.ecs_service_target_group_healthy
  #   unhealthy_threshold = var.ecs_service_target_group_unhealthy
  # }

  tags = {
    Name        = "${local.name_suffix}-tg"
    app         = var.project
    environment = terraform.workspace
  }
}

# Create an Application Load Balancer
resource "aws_alb" "my_alb" {
  name                       = "${local.name_suffix}-alb"
  load_balancer_type         = "application"
  internal                   = false
  security_groups            = var.alb_security_groups
  subnets                    = flatten(var.public_subnet_ids)
  enable_cross_zone_load_balancing = "true"
  tags = {
    Name        = "${local.name_suffix}-alb"
    app         = var.project
    environment = terraform.workspace
  }
}

resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_alb.my_alb.arn
  port              = 80

  default_action {
    target_group_arn = aws_alb_target_group.my_tg.arn
    type             = "forward"
  }

  # depends_on = [aws_alb_target_group.my_tg]

  tags = {
    Name        = "${local.name_suffix}-alb"
    app         = var.project
    environment = terraform.workspace
  }
}

