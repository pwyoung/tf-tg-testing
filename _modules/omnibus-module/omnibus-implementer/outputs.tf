output "aws_region_names" {
  value = module.aws_regions.region_names
}

output "region_names_downcased" {
  value = module.aws_regions.region_names_downcased
}

output "ec2_public_ips" {
  value = module.aws_regions.ec2_public_ips
}

output "ec2_public_dns_list" {
  value = module.aws_regions.ec2_public_dns_list
}

output "ec2_private_ips" {
  value = module.aws_regions.ec2_private_ips
}
