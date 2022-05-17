# EC2 INSTANCE

variable "name" {}
variable "subnet_id" {}
variable "key_name" {}
variable "vpc_id" {}

# Create these objects using these names
# TODO: consider adding support for using "data" to
#       fetch and use these if they exist
variable "ec2_security_group_name" {}
variable "ec2_iam_policy_name" {}
variable "ec2_iam_role_name" {}
variable "ec2_instance_profile_name" {}

variable "tags" {}

variable "ec2_instance_type" {
  default = "t3a.medium"
}


# sudo apt install -y postgresql-client htop iperf3 tree awscli mysql-client nfs-common redis-tools> /tmp/apt-install.log
variable "user_data" {
  default = <<-EOT
    #!/bin/bash
    sudo apt update > /tmp/apt-update.log
EOT
}

variable "ingress_cidr_blocks" {}
variable "ingress_rules" {}
variable "egress_rules" {}
variable "ingress_with_cidr_blocks" {}

variable "policy" {}
variable "assume_role_policy" {}

variable "associate_public_ip_address" {
  default = false
}

