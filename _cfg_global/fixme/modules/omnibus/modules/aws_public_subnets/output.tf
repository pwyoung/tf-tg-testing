output "vpc_id" {
  value = var.vpc_id
}


output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = aws_subnet.public[*].id
}
