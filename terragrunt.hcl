# https://terragrunt.gruntwork.io/docs/features/keep-your-remote-state-configuration-dry/
#
# Example:
#   https://github.com/gruntwork-io/terragrunt-infrastructure-live-example/blob/4a8569c33088e13938d412f65a27a16d4e2d524b/terragrunt.hcl


# Create a default provider (in the terragrunt cache folder for the module executed)
#
# Generate an AWS provider block
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.aws_region}"

  # Only these AWS Account IDs may be operated on by this template
  allowed_account_ids = ["${local.account_id}"]
}
EOF
}



# Create a backend.tf file (in the folder where the module is executed)
#
remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    bucket         = "pwy-tf-tg-testing-20220517"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "pwy-tgstate-conntest"
  }
  # Allow 'TERRAGRUNT_DISABLE_INIT=true terragrunt run-all validate'
  # to run without creating the remote backend
  # See: https://terragrunt.gruntwork.io/docs/reference/config-blocks-and-attributes/
  disable_init = tobool(get_env("TERRAGRUNT_DISABLE_INIT", "false"))
}


locals {
  # Automatically load account-level variables
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract the variables we need for easy access
  account_name = local.account_vars.locals.account_name
  account_id   = local.account_vars.locals.aws_account_id
  aws_region   = local.region_vars.locals.aws_region
}


# ---------------------------------------------------------------------------------------------------------------------
# GLOBAL PARAMETERS
# These variables apply to all configurations in this subfolder. These are automatically merged into the child
# `terragrunt.hcl` config via the include block.
# ---------------------------------------------------------------------------------------------------------------------

# Unused variables are pruned by TF
# That is visible in the debug output of 'terragrunt apply .tfplan --terragrunt-log-level debug --terragrunt-debug'
#
# Configure root level variables that all resources can inherit. This is especially helpful with multi-account configs
# where terraform_remote_state data sources are placed directly into the modules.
inputs = merge(
  local.account_vars.locals,
  local.region_vars.locals,
  local.environment_vars.locals,
)
