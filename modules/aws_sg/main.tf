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

data "aws_vpc" "selected" {
  id = var.vpc_id
}

# Application Load Balancer Security group
resource "aws_security_group" "alb" {
  name        = "${local.name_suffix}-alb"
  description = "ALB-traffic - ${var.description}"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "${local.name_suffix}-alb"
    app         = var.project
    environment = terraform.workspace
  }
}

# EC2 nodes Security group
resource "aws_security_group" "ec2" {
  name        = "${local.name_suffix}-ec2"
  description = "ECS-traffic - ${var.description}"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "${local.name_suffix}-ec2"
    app         = var.project
    environment = terraform.workspace
  }
}

/*
Inbound rules for EC2 and ALBs
*/

# Range of TCP ports on the EC2 instances - Traffic comes from the Load Balancers
resource "aws_security_group_rule" "to_ec2_from_alb" {
  type                     = "ingress"
  description              = "Allowed ports from the alb - ${var.description}"
  from_port                = "80"
  to_port                  = "80"
  protocol                 = "TCP"
  source_security_group_id = aws_security_group.alb.id
  security_group_id        = aws_security_group.ec2.id
}

# Allow Load Balancer access from Internet
resource "aws_security_group_rule" "to_alb_from_internet" {
  type              = "ingress"
  description       = "ALB-traffic - ${var.description}"
  from_port         = "80"
  to_port           = "80"
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
}

/*
Outbound rules for EC2 and ALB
*/

# Outbound rules for ec2s
resource "aws_security_group_rule" "ec2_all" {
  type              = "egress"
  description       = "ec2-all - ${var.description}"
  to_port           = 0
  protocol          = "-1"
  from_port         = 0
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ec2.id
}

# Outbound rules for albs
resource "aws_security_group_rule" "alb_all" {
  type              = "egress"
  description       = "ALB-traffic - ${var.description}"
  to_port           = 0
  protocol          = "-1"
  from_port         = 0
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
}
