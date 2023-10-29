output "alb_name" {
  value = aws_alb.my_alb.dns_name
}

output "alb_arn" {
  value = aws_alb.my_alb.arn
}
