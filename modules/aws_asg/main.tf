locals {
  name_suffix = "${var.project}-${terraform.workspace}"
}

data "template_file" "user_data" {
  template = file("${path.module}/user-data.sh")
}

resource "aws_launch_template" "my_launch_template" {
  name          = local.name_suffix
  image_id      = var.ec2_ami
  instance_type = var.ec2_instance_type
  key_name      = var.key_pair_name
  user_data     = base64encode(data.template_file.user_data.rendered)

  iam_instance_profile {
    name = var.iam_instance_role_name
  }

  monitoring {
    enabled = true
  }

  vpc_security_group_ids = var.security_group_ids

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      encrypted   = true
      volume_type = var.volume_type
      volume_size = var.ec2_root_block_device_size
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    environment = terraform.workspace
  }
}

# Auto scaling group for Production
resource "aws_autoscaling_group" "my_asg" {
  name = local.name_suffix

  min_size         = var.asg_min_size
  max_size         = var.asg_max_size
  desired_capacity = var.asg_size

  vpc_zone_identifier       = var.vpc_ec2_subnet_ids
  termination_policies      = ["OldestInstance"]
  protect_from_scale_in     = var.scale_in_protection
  health_check_grace_period = var.health_check_grace_period
  launch_template {
    id      = aws_launch_template.my_launch_template.id
    version = "$Latest"
  }

  provisioner "local-exec" {
    command = "sleep ${var.asg_size == 0 ? 0 : var.sleep_time}"
  }

  tag {
    key                 = "Name"
    value               = "${local.name_suffix}-node"
    propagate_at_launch = true
  }

  tag {
    key                 = "app"
    value               = var.project
    propagate_at_launch = true
  }

  tag {
    key                 = "environment"
    value               = terraform.workspace
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_lifecycle_hook" "my_lifecycle_hook" {
  name                   = "${local.name_suffix}-draining-process"
  autoscaling_group_name = aws_autoscaling_group.my_asg.name
  default_result         = "ABANDON"
  heartbeat_timeout      = var.draining_process_lifecycle_timeout
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_TERMINATING"
}
