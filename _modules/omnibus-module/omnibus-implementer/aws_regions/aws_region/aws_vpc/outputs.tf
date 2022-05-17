output "ec2_public_ips" {
  value = flatten( module.public_ubuntu_instances[*].ec2_public_ip )
  description = "The public ips for the public ec2 instances in the vpc"
}

output "ec2_public_dns_list" {
  value = flatten( module.public_ubuntu_instances[*].ec2_public_dns )
  description = "The public dnss for the public ec2 instances in the vpc"
}

output "ec2_private_ips" {
  value = flatten( module.private_ubuntu_instances[*].ec2_private_ip )
  description = "The private ips for the private ec2 instances in the vpc"
}
