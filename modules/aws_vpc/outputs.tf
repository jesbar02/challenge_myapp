output "vpc_id" {
  value = aws_vpc.my_vpc.id
}

output "vpc_cidr_block" {
  value = aws_vpc.my_vpc.cidr_block
}

output "private_subnet_ids" {
  value = aws_subnet.private.*.id
}

output "public_subnet_ids" {
  value = aws_subnet.public.*.id
}

output "private_subnet_blocks" {
  value = aws_subnet.private.*.cidr_block
}

output "public_subnet_blocks" {
  value = aws_subnet.public.*.cidr_block
}
