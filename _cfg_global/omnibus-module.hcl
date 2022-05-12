# For an example of this file/pattern, see:
#   https://github.com/gruntwork-io/terragrunt-infrastructure-live-example/blob/4a8569c33088e13938d412f65a27a16d4e2d524b/_envcommon/mysql.hcl

terraform {
  source = "${local.base_source_url}?ref=v0.7.0"
}

# Locals are named constants that are reusable within the configuration.
locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract out common variables for reuse
  env = local.environment_vars.locals.environment

  #region = local.aws_region # PWY:Added. Pulls in from global.hcl

  # Expose the base source URL so different versions of the module can be deployed in different environments. This will
  # be used to construct the terraform block in the child terragrunt configurations.
  base_source_url = "git::git@github.com:gruntwork-io/terragrunt-infrastructure-modules-example.git//mysql"
}

# MODULE PARAMETERS
# These are the variables we have to pass in to use the module.
# This defines the parameters that are common across all environments.
inputs = {
  name              = "mysql_${local.env}"
  instance_class    = "db.t2.micro"
  allocated_storage = 20
  storage_type      = "standard"
  master_username   = "admin"

  #region = "us-east-1" # "${local.region}" # PWY: Added. Pulls from above


  # TODO: To avoid storing your DB password in the code, set it as the environment variable TF_VAR_master_password
}