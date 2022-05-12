locals {
  private_subnet_cidrs = contains(keys(jsondecode(var.aws_vpc_cfg).private_subnets), "cidrs") ? jsondecode(var.aws_vpc_cfg)["private_subnets"].cidrs : []

  # default_private_inbound_acl_rules
  dviacr = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
  ]

  private_inbound_acl_rules = contains(keys(jsondecode(var.aws_vpc_cfg).private_subnets), "private_inbound_acl_rules") ? jsondecode(var.aws_vpc_cfg).private_subnets.private_inbound_acl_rules : local.dviacr


  # default_private_outbound_acl_rules = [
  dvoar = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
  ]

  private_outbound_acl_rules = contains(keys(jsondecode(var.aws_vpc_cfg).private_subnets), "private_outbound_acl_rules") ? jsondecode(var.aws_vpc_cfg).private_subnets.private_outbound_acl_rules : local.dvoar

}

module "private_subnets" {
  count = length(local.private_subnet_cidrs) > 0 ? 1 : 0

  source = "../aws_private_subnets"

  vpc_id = aws_vpc.this.id

  # The public NAT Gateways will go into these
  public_subnet_ids = module.public_subnets[0].public_subnet_ids

  private_subnet_cidrs = local.private_subnet_cidrs

  azs = ["${local.region}a", "${local.region}b", "${local.region}c"]

  private_inbound_acl_rules = local.private_inbound_acl_rules

  private_outbound_acl_rules = local.private_outbound_acl_rules

  tags = {
    Name   = "priv-${local.app_id}-${local.owner}-${local.env}-${local.region}"
    App-ID = local.app_id,
    Owner  = local.owner,
    Env    = local.env,
    Region = local.region
  }

}

