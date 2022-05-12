output "vpc_id" {
  value = var.vpc_id
}


output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = aws_subnet.private[*].id
}
