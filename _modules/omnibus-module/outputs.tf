output "aws_region_names" {
  value       = module.root.aws_region_names
  description = "List the AWS Region names found in the config"
}

output "aws_region_names_downcased" {
  value       = module.root.region_names_downcased
  description = "List the AWS Region names read from the individual statically-defined modules"
}

output "ec2_public_ips" {
  value = module.root.ec2_public_ips
  description = "List the public IPs for EC2 public instances"
}

output "ec2_public_dns_list" {
  value = module.root.ec2_public_dns_list
  description = "List the public DNS List for EC2 public instances"
}

output "ec2_private_ips" {
  value = module.root.ec2_private_ips
  description = "List the private IPs for EC2 private instances"
}

# Output as JSON so that the structure can be preserved.
