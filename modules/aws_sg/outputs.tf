output "sg_ec2_id" {
  value = aws_security_group.ec2.id
}

output "sg_alb_id" {
  value = aws_security_group.alb.id
}

