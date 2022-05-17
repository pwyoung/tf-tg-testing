output "aws_region_names" {
  value = module.aws_regions.region_names
}

#module.aws_regions.module.us-west-1[0].module.vpc[0].module.private_ubuntu_instances[0].module.ec2_instance.aws_instance.this[0]