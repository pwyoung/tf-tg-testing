module "private_ubuntu_instances" {
  # If there are no private subnets, then do not create this
  count = length(module.private_subnets) > 0 ? jsondecode(var.aws_vpc_cfg).private_ec2_instances.number_of_ec2_instances : 0

  source = "./aws_ec2_ubuntu_instance"

  # DO NOT create an EIP to this instance so that we can connect to it from the internet
  associate_public_ip_address = false

  vpc_id = aws_vpc.this.id

  subnet_id = element(module.private_subnets[0].private_subnet_ids, count.index)

  key_name = jsondecode(var.aws_vpc_cfg).private_ec2_instances.ec2_key_name

  ec2_instance_type = jsondecode(var.aws_vpc_cfg).private_ec2_instances.ec2_instance_type

  user_data = <<-EOT
    #!/bin/bash
    sudo apt update > /tmp/apt-update.log
    sudo apt install -y postgresql-client htop iperf3 tree awscli mysql-client nfs-common redis-tools> /tmp/apt-install.log
EOT

  # EC2 Security Group parameters
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["all-icmp"]
  egress_rules        = ["all-all"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 2049
      to_port     = 2049
      protocol    = "udp"
      description = "Allow UDP to port 2049 for NFSv4"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "Allow all TCP"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  # EC2 IAM POLICY
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "s3:Get*",
            "s3:List*",
            "s3-object-lambda:Get*",
            "s3-object-lambda:List*"
          ],
          "Resource" : [
            "arn:aws:s3:::todo-changeme"
          ]
        },
      ]
  })
  # This is called the "Trust Relationship" in the AWS Management Console
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = ["ec2.amazonaws.com"]
        }
      },
    ]
  })

  # Prevent name collisions for the objects created here
  # TODO: make this more efficient by checking to see if they exist already (via Terraform Data API)
  #
  # EC2 SECURITY GROUP
  ec2_security_group_name = "private-ubuntu-${local.app_id}-${local.env}-${local.region}-${count.index}"
  #
  # IAM OBJECTS
  #   The role contains the assume-role-policy
  ec2_iam_role_name = "private-ubuntu-${local.app_id}-${local.env}-${local.region}-${count.index}"
  #   The IAM role will be attached to an object containing the actual policy
  ec2_iam_policy_name = "private-ubuntu-${local.app_id}-${local.env}-${local.region}-${count.index}"
  #   The role will be attached to an Instance Profile (which will be applied to the EC2 instance)
  ec2_instance_profile_name = "private-ubuntu-${local.app_id}-${local.env}-${local.region}-${count.index}"

  name = "prv-${local.app_id}-${local.owner}-${local.env}-${local.region}-${count.index}"
  tags = {
    App-ID = local.app_id,
    Owner  = local.owner,
    Env    = local.env,
    Region = local.region
  }

}
