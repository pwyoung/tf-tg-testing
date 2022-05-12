# This will be read by the top-level terragrunt.hcl
# when it generates an AWS provider block dynamically

# Example:
#   https://github.com/gruntwork-io/terragrunt-infrastructure-live-example/blob/4a8569c33088e13938d412f65a27a16d4e2d524b/non-prod/us-east-1/region.hcl
#
# Set common variables for the region. This is automatically pulled in in the root terragrunt.hcl configuration to
# configure the remote state bucket and pass forward to the child modules as inputs.
locals {
  aws_region = "us-east-1"
}
