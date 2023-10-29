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

data "aws_availability_zones" "available" {}

# Create VPC
resource "aws_vpc" "my_vpc" {
  cidr_block           = var.cidr_block
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = local.tags
}

# Create public subnet, routes and associations
resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name        = "${local.name_suffix}-public-${data.aws_availability_zones.available.names[count.index]}"
    app         = var.project
    environment = terraform.workspace
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name        = "${local.name_suffix}-public"
    app         = var.project
    environment = terraform.workspace
  }
}

resource "aws_internet_gateway" "my_vpc_ig" {
  vpc_id = aws_vpc.my_vpc.id

  tags = local.tags
}

resource "aws_route" "internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.my_vpc_ig.id
}

resource "aws_eip" "my_eip" {
  vpc = true

  tags = {
    Name        = "${local.name_suffix}-nat-eip"
    project     = var.project
    environment = terraform.workspace
  }
}

resource "aws_nat_gateway" "my_nat_gateway" {
  allocation_id = aws_eip.my_eip.id
  subnet_id     = aws_subnet.public[var.nat_gateway_public_subnet_index].id

  tags = {
    Name        = "${local.name_suffix}-nat"
    app         = var.project
    environment = terraform.workspace
  }
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
  depends_on     = [aws_subnet.public]
}

# Create private subnet, routes and associations
resource "aws_subnet" "private" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name        = "${local.name_suffix}-private-${data.aws_availability_zones.available.names[count.index]}"
    app         = var.project
    environment = terraform.workspace
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name        = "${local.name_suffix}-private"
    app         = var.project
    environment = terraform.workspace
  }
}

resource "aws_route" "private" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.my_nat_gateway.id
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.private.id
  depends_on     = [aws_subnet.private]
}
