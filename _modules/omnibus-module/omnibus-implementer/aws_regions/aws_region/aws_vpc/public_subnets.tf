locals {
  public_subnet_cidrs = contains(keys(jsondecode(var.aws_vpc_cfg).public_subnets), "cidrs") ? jsondecode(var.aws_vpc_cfg)["public_subnets"].cidrs : []

  # default_public_inbound_acl_rules
  dpiacr = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
  ]

  public_inbound_acl_rules = contains(keys(jsondecode(var.aws_vpc_cfg).public_subnets), "public_inbound_acl_rules") ? jsondecode(var.aws_vpc_cfg).public_subnets.public_inbound_acl_rules : local.dpiacr


  # default_public_outbound_acl_rules = [
  dpoar = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
  ]

  public_outbound_acl_rules = contains(keys(jsondecode(var.aws_vpc_cfg).public_subnets), "public_outbound_acl_rules") ? jsondecode(var.aws_vpc_cfg).public_subnets.public_outbound_acl_rules : local.dpoar

}


module "public_subnets" {
  count = length(local.public_subnet_cidrs) > 0 ? 1 : 0

  source = "./aws_public_subnets"

  vpc_id = aws_vpc.this.id

  public_subnet_cidrs = local.public_subnet_cidrs

  azs = ["${local.region}a", "${local.region}b", "${local.region}c"]

  public_inbound_acl_rules = local.public_inbound_acl_rules

  public_outbound_acl_rules = local.public_outbound_acl_rules

  tags = {
    Name   = "pub-${local.app_id}-${local.owner}-${local.env}-${local.region}"
    App-ID = local.app_id,
    Owner  = local.owner,
    Env    = local.env,
    Region = local.region
  }

}

