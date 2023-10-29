# Define input variables
variable "region" {
  default     = "us-east-1"
  description = "AWS region where the VPC will be created."
}

variable "project" {
  default = "myapp"
}
