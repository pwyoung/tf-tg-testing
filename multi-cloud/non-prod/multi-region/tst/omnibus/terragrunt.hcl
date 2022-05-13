# Example of this pattern:
#   https://github.com/gruntwork-io/terragrunt-infrastructure-live-example/blob/4a8569c33088e13938d412f65a27a16d4e2d524b/non-prod/us-east-1/stage/mysql/terragrunt.hcl

# Include the top-level terragrunt.hcl file
# This does thigs like:
# - manage the backend (backend.tf files, if we are using that, which we should)
# - manage the default AWS provider (so that the region is automatically applied)
# - create some global parameters
include "root" {
  path = find_in_parent_folders()
}


# Include code that:
# - defines and invokes our module
# - sets some TG-inputs (e.g. env)
include "call_module" {
  path = "${dirname(find_in_parent_folders())}/_cfg_global/omnibus-module.hcl"
}

# MODULE PARAMETERS
#   These are the variables we have to pass in to use the module.
#   This defines the parameters that are common across all environments.
#   TG transforms these to "TF_VAR_<input_name>=<input_value>" in the TF run.
inputs = {
  # "env" is set via omnibus-module.hcl

  # TODO, put at least this (and maybe others) in a file "./<FOO>.tfvars"
  public_ec2_key_name = "tardis"

  public_ec2_instance_type = "t3.medium"

  app_id = "conntest"
  owner = "pwy"

}
