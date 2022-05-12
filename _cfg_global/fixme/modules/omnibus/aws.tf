# Build things define in the "aws" section of the config


# Build the AWS network
module "aws_regions" {
  source = "./modules/aws_regions"

  env             = jsondecode(var.cfg).env
  meta_data       = jsonencode(jsondecode(var.cfg).meta_data)
  aws_regions_cfg = jsonencode(jsondecode(var.cfg).aws.regions)
}
