# get this from this module
output "region_downcased" {
  value = local.region
}

output "ec2_public_ips" {
  value = flatten(module.vpc[*].ec2_public_ips)
  description = "The public ips for the public ec2 instances in the region"
}

output "ec2_public_dns_list" {
  value = flatten(module.vpc[*].ec2_public_dns_list)
  description = "The public dns for the public ec2 instances in the region"
}

output "ec2_private_ips" {
  value = flatten(module.vpc[*].ec2_private_ips)
  description = "The private ips for the private ec2 instances in the region"
}
