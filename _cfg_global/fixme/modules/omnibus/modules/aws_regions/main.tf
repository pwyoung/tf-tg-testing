locals {
  # Get the name of the regions in the config
  region_names = keys(jsondecode(var.aws_regions_cfg))

}

# Deal with the fact that the AWS Provider is arguably stuck with a bad design
# Details, e.g. per https://github.com/hashicorp/terraform/issues/16967#issuecomment-1063328148
#   Terraform/Hashicorp seems to prefer having a directory in the terraform code per AWS Region
#   even though other providers, like Google do not require it, and
#   other providers, like Helm/K8S providers, would benefit from "count/foreach" in the Provider statement.
# Hard code the region and modules since we want Terraform to know WHICH region is added/removed
# whenever regions are added/removed to the config

provider "aws" {
  # count = 1 # This is not supported (but might be in future)
  alias  = "us-east-1"
  region = "us-east-1"
}

provider "aws" {
  alias  = "us-east-2"
  region = "us-east-2"
}

provider "aws" {
  alias  = "us-west-1"
  region = "us-west-1"
}

provider "aws" {
  alias  = "us-west-2"
  region = "us-west-2"
}


################################################################################
# Execute each Region using the provider for that region
################################################################################

module "us-east-1" {
  count  = contains(keys(jsondecode(var.aws_regions_cfg)), "us-east-1") ? 1 : 0
  source = "../aws_region"
  providers = {
    aws = aws.us-east-1
  }

  env            = var.env
  meta_data      = var.meta_data
  region         = "us-east-1"
  aws_region_cfg = jsonencode(jsondecode(var.aws_regions_cfg)["us-east-1"])
}

module "us-east-2" {
  count  = contains(keys(jsondecode(var.aws_regions_cfg)), "us-east-2") ? 1 : 0
  source = "../aws_region"
  providers = {
    aws = aws.us-east-2
  }

  env            = var.env
  meta_data      = var.meta_data
  region         = "us-east-2"
  aws_region_cfg = jsonencode(jsondecode(var.aws_regions_cfg)["us-east-2"])
}

module "us-west-1" {
  count  = contains(keys(jsondecode(var.aws_regions_cfg)), "us-west-1") ? 1 : 0
  source = "../aws_region"
  providers = {
    aws = aws.us-west-1
  }

  env            = var.env
  meta_data      = var.meta_data
  region         = "us-west-1"
  aws_region_cfg = jsonencode(jsondecode(var.aws_regions_cfg)["us-west-1"])
}

module "us-west-2" {
  count  = contains(keys(jsondecode(var.aws_regions_cfg)), "us-west-2") ? 1 : 0
  source = "../aws_region"
  providers = {
    aws = aws.us-west-2
  }

  env            = var.env
  meta_data      = var.meta_data
  region         = "us-west-2"
  aws_region_cfg = jsonencode(jsondecode(var.aws_regions_cfg)["us-west-2"])
}
