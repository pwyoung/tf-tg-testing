locals {
  env = lower(var.env)

  meta_data = var.meta_data

  region = lower(var.region)

  aws_vpc_config = jsonencode(jsondecode(var.aws_region_cfg)["vpc"])

}

module "vpc" {
  count = length(local.aws_vpc_config) > 0 ? 1 : 0

  source = "./aws_vpc"

  env         = var.env
  meta_data   = var.meta_data
  region      = var.region
  aws_vpc_cfg = local.aws_vpc_config
}
