variable "project" {}

# Locals variables to improve the consistency of resources tags.
variable "Name" {
  type    = string
  default = ""
}

variable "vpc_id" {
}

variable "resource_tags" {
  type    = map(string)
  default = {}
}

variable "description" {
  default = "Terraform"
}