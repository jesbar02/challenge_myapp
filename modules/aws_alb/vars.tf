variable "project" {}

variable "vpc_id" {}

variable "public_subnet_ids" {}

variable "alb_security_groups" {}

# Target group
variable "ecs_service_target_group_name" {
  default = ""
}

variable "ecs_service_target_group_timeout" {
  default = 3
}

variable "ecs_service_target_group_interval" {
   default = 5
} 

variable "ecs_service_target_group_unhealthy" {
  default = 5
}

variable "ecs_service_target_group_healthy" {
  default = 5
}

variable "ecs_service_target_group_path" {
  default = "/"
}

variable "ecs_service_target_group_status" {
  default = 200
}

# Locals variables to improve the consistency of resources tags.
variable "Name" {
  type    = string
  default = ""
}

variable "resource_tags" {
  type    = map(string)
  default = {}
}
