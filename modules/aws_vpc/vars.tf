## Module Default variables

# variable "region" {
#   type    = string
#   default = ""
# }

variable "project" {}

variable "cidr_block" {}

variable "enable_dns_support" {
  default = true
}

variable "enable_dns_hostnames" {
  default = true
}

variable "public_subnets" {
  type    = list(string)
  default = []
}

variable "private_subnets" {
  type    = list(string)
  default = []
}

variable "nat_gateway_public_subnet_index" {
  default = ""
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
