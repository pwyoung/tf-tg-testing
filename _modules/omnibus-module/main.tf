module "root" {
  # TODO: for serious stuff, replace this with a git url (pinned to a version)
  source = "./omnibus-implementer"

  cfg = jsonencode(
    {
      # ENVIRONMENT
      env = "${var.env}"

      # APP COMMON (META) DATA
      meta_data = {
        app_id = "${var.app_id}"
        owner  = "${var.owner}"
      }

      # AWS
      aws = {
        regions = {
          "us-west-1" = {
            vpc = {
              vpc_cidr_block        = "10.100.0.0/16"
              secondary_cidr_blocks = []
              public_subnets = {
                cidrs = ["10.100.101.0/24", "10.100.102.0/24"] # There is no us-west-1c # , "10.100.103.0/24"]
                public_inbound_acl_rules = [
                  {
                    rule_number = 100
                    rule_action = "allow"
                    from_port   = 0
                    to_port     = 0
                    protocol    = "-1"
                    cidr_block  = "0.0.0.0/0"
                  },
                ]
                public_outbound_acl_rules = [
                  {
                    rule_number = 100
                    rule_action = "allow"
                    from_port   = 0
                    to_port     = 0
                    protocol    = "-1"
                    cidr_block  = "0.0.0.0/0"
                  },
                ]
              }
              private_subnets = {
                # Each cidr/subnet gets a NAT Gateway
                # Commenting out the cidrs or making the list empty will remove the private subnets
                cidrs = ["10.100.201.0/24"] # , "10.100.202.0/24"] # There is no us-west-1c # , "10.100.203.0/24"]
              }
              public_ec2_instances = {
                number_of_ec2_instances = 1
                ec2_key_name            = "${var.public_ec2_key_name}"
                ec2_instance_type       = "${var.public_ec2_instance_type}"
              }
              private_ec2_instances = {
                number_of_ec2_instances = 1
                ec2_key_name            = "${var.private_ec2_key_name}"
                ec2_instance_type       = "${var.private_ec2_instance_type}"
              }
            }
          }
          "us-east-2" = {
            vpc = {
              vpc_cidr_block        = "10.101.0.0/16"
              secondary_cidr_blocks = []
              public_subnets = {
                cidrs = ["10.101.101.0/24", "10.101.102.0/24", "10.101.103.0/24"]
                #public_inbound_acl_rules # rely on defaults in module
                #public_outbound_acl_rules # rely on defaults in module
              }
              private_subnets = {
                #cidrs = [] # save on NAT Gateway costs # ["10.101.201.0/24"]
                #private_inbound_acl_rules # rely on defaults in module
                #private_outbound_acl_rules # rely on defaults in module
              }
              public_ec2_instances = {
                number_of_ec2_instances = 0
                ec2_key_name            = "${var.public_ec2_key_name}"
                ec2_instance_type       = "${var.public_ec2_instance_type}"
              }
              private_ec2_instances = {
                number_of_ec2_instances = 0
                ec2_key_name            = "${var.private_ec2_key_name}"
                ec2_instance_type       = "${var.private_ec2_instance_type}"
              }
            }
          }
          "us-west-2" = {
            vpc = {
              vpc_cidr_block        = "10.102.0.0/16"
              secondary_cidr_blocks = []
              public_subnets = {
                cidrs = ["10.102.101.0/24", "10.102.102.0/24", "10.102.103.0/24"]
              }
              private_subnets = {
              }
              public_ec2_instances = {
                number_of_ec2_instances = 0
                ec2_key_name            = "${var.public_ec2_key_name}"
                ec2_instance_type       = "${var.public_ec2_instance_type}"
              }
              private_ec2_instances = {
                number_of_ec2_instances = 0
                ec2_key_name            = "${var.private_ec2_key_name}"
                ec2_instance_type       = "${var.private_ec2_instance_type}"
              }
            }
          }
        }
      }

      # TODO: add other Clouds
      # GCP
      # Azure

    }
  )

}
