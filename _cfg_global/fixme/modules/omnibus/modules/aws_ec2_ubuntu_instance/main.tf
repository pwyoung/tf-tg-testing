# UBUNTU EC2 INSTANCE

locals {
  ec2_instance_name = var.name
  ec2_subnet_id     = var.subnet_id
  key_name          = var.key_name
  vpc_id            = var.vpc_id

  ec2_security_group_name   = var.ec2_security_group_name
  ec2_iam_policy_name       = var.ec2_iam_policy_name
  ec2_iam_role_name         = var.ec2_iam_role_name
  ec2_instance_profile_name = var.ec2_instance_profile_name

  ec2_tags          = var.tags
  ec2_instance_type = var.ec2_instance_type
  user_data         = var.user_data

}

# Ubuntu AMI
#   https://cloud-images.ubuntu.com/locator/ec2/
data "aws_ami" "ubuntu_private_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


module "ec2_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"
  # Forked at https://github.com/pwyoung/terraform-aws-security-group

  name        = local.ec2_security_group_name
  description = "Security group for ${local.ec2_instance_name}"
  # https://github.com/terraform-aws-modules/terraform-aws-vpc/blob/master/outputs.tf#L1
  vpc_id = local.vpc_id

  # Allow ingress rules to be accessed only within current VPC
  # Allow ingress from anywhere
  ingress_cidr_blocks = var.ingress_cidr_blocks

  ingress_rules = var.ingress_rules
  egress_rules  = var.egress_rules

  ingress_with_cidr_blocks = var.ingress_with_cidr_blocks

  tags = local.ec2_tags

}

# IAM Policy
#  Allow the ec2 instance to assume the role that allows it to read from our s3 bucket

# "Example policy that grants a user permission to use the Amazon EC2 console to launch an instance with any role"
# https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_switch-role-ec2.html#roles-usingrole-ec2instance-permissions
resource "aws_iam_policy" "ec2_iam_policy" {
  name        = local.ec2_iam_policy_name
  path        = "/"
  description = "Allow "

  policy = var.policy
}


# Create a role and allow it to be assumed by an EC2 intance
resource "aws_iam_role" "ec2_custom_role" {
  name = local.ec2_iam_role_name

  # This is called the "Trust Relationship" in the AWS Management Console
  assume_role_policy = var.assume_role_policy
}


# Attach the ec2 IAM Policy to the ec2 IAM Role
resource "aws_iam_role_policy_attachment" "attach_ec2_policy_and_role" {
  role       = aws_iam_role.ec2_custom_role.name
  policy_arn = aws_iam_policy.ec2_iam_policy.arn
}


# Create the EC2 Instance Profile, which contains the EC2 custom role
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = local.ec2_instance_profile_name
  role = aws_iam_role.ec2_custom_role.name
}

# EC2 INSTANCE
#   https://github.com/terraform-aws-modules/terraform-aws-ec2-instance/blob/master/main.tf
module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = local.ec2_instance_name

  ami = data.aws_ami.ubuntu_private_ami.id

  instance_type = local.ec2_instance_type

  # AWS (SSH) KeyPair name
  key_name = local.key_name

  monitoring             = true
  vpc_security_group_ids = [module.ec2_security_group.security_group_id]
  subnet_id              = local.ec2_subnet_id

  # https://github.com/terraform-aws-modules/terraform-aws-ec2-instance/blob/master/examples/complete/main.tf#L97
  associate_public_ip_address = var.associate_public_ip_address

  tags = local.ec2_tags

  user_data_base64 = base64encode(local.user_data)

  #https://github.com/terraform-aws-modules/terraform-aws-ec2-instance/blob/master/variables.tf#L92
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

  # TODO: consider
  # instance_initiated_shutdown_behavior = "terminate"
  # monitoring: https://github.com/terraform-aws-modules/terraform-aws-ec2-instance/blob/master/variables.tf#L139
  # placement_group             = aws_placement_group.web.id

}
