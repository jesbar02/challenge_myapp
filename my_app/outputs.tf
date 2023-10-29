output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  value = module.vpc.vpc_cidr_block
}

output "private_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "public_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "private_subnet_blocks" {
  value = module.vpc.private_subnet_blocks
}

output "public_subnet_blocks" {
  value = module.vpc.public_subnet_blocks
}

output "alb_name" {
  value = module.alb.alb_name
}

output "alb_arn" {
  value = module.alb.alb_arn
}
