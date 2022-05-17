
# https://github.com/terraform-aws-modules/terraform-aws-ec2-instance/blob/master/outputs.tf
output "ec2_public_ip" {
  value = module.ec2_instance.public_ip
  description = "The public ip for the public ec2 instance"
}

output "ec2_public_dns" {
  value = module.ec2_instance.public_dns
  description = "The public dns for the public ec2 instance"
}

output "ec2_private_ip" {
  value = module.ec2_instance.private_ip
  description = "The private ip for the private ec2 instance"
}
