# Get the name of the regions in the config
output "region_names" {
  value = keys(jsondecode(var.aws_regions_cfg))
}

# Get the region names from the individual modules
output "region_names_downcased" {
  # https://www.terraform.io/language/functions/merge
  value = flatten ([
    module.us-east-1[*].region_downcased,
    module.us-east-2[*].region_downcased,
    module.us-west-1[*].region_downcased,
    module.us-west-2[*].region_downcased
    ])
}

# Get the public IPs for the public ec2 instances
output "ec2_public_ips" {
  value = flatten ([
      module.us-east-1[*].ec2_public_ips,
      module.us-east-2[*].ec2_public_ips,
      module.us-west-1[*].ec2_public_ips,
      module.us-west-2[*].ec2_public_ips
    ])
}

# Get the public DNS list for the public ec2 instances
output "ec2_public_dns_list" {
  value = flatten ([
      module.us-east-1[*].ec2_public_dns_list,
      module.us-east-2[*].ec2_public_dns_list,
      module.us-west-1[*].ec2_public_dns_list,
      module.us-west-2[*].ec2_public_dns_list
    ])
}

# Get the private IPs for the private ec2 instances
output "ec2_private_ips" {
  value = flatten ([
      module.us-east-1[*].ec2_private_ips,
      module.us-east-2[*].ec2_private_ips,
      module.us-west-1[*].ec2_private_ips,
      module.us-west-2[*].ec2_private_ips
    ])
}
