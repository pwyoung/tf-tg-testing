# This is the common stuff expected to be TG-included by terragrunt.hcl
# in the directories where this module is called by TG, e.g. 'dev/omnibus/'

terraform {
  # Keep this as a reminder to move to git-based modules
  #source = "${local.base_source_url}?ref=v0.7.0"
  source = "${dirname(find_in_parent_folders())}/_modules/omnibus-module"
}

# TG Locals
locals {
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env = local.environment_vars.locals.environment

  # Keep this as a reminder to move to git-based modules
  #base_source_url = "git::git@github.com:gruntwork-io/terragrunt-infrastructure-modules-example.git//mysql"
}

# MODULE PARAMETERS
#   This defines the parameters that are common across all environments.
#   TG transforms these to "TF_VAR_<input_name>=<input_value>" in the TF run,
#   in order to set the corresponding variable(s) required by the module.
inputs = {
  env = local.env
}