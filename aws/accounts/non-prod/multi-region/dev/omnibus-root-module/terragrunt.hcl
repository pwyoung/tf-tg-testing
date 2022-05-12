# Example of this pattern:
#   https://github.com/gruntwork-io/terragrunt-infrastructure-live-example/blob/4a8569c33088e13938d412f65a27a16d4e2d524b/non-prod/us-east-1/stage/mysql/terragrunt.hcl

include "root" {
  path = find_in_parent_folders()
}

# Globals
include "_cfg_global" {
  path = "${dirname(find_in_parent_folders())}/_cfg_global/omnibus-module.hcl"
}
