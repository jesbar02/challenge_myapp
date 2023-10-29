variable "project" {}

variable "ec2_ami" {
  default = "ami-01eccbf80522b562b"
}

variable "environment" {
  default = ""
}

variable "ec2_instance_type" {
  default = "t3.small"
}

variable "key_pair_name" {
  default = "silos-general"
}

variable "iam_instance_role_name" { ### just defaulted to make testings, can be one of your needs
  default = "SSMAccess"
}

variable "security_group_ids" {}

variable "volume_type" {
  default = "gp2"
}

variable "ec2_root_block_device_size" {
  default = 20
}

variable "draining_process_lifecycle_timeout" {
  default = 3600
}

variable "asg_min_size" {
  default = 0
}

variable "asg_max_size" {
  default = 0
}

variable "asg_size" {
  default = 0
}

variable "vpc_ec2_subnet_ids" {
  type = list(string)
}

variable "scale_in_protection" {
  default = false
}

variable "health_check_grace_period" {
  default = 0
}

variable "sleep_time" {
  default = 150
}
