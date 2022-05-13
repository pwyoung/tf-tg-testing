# PURPOSE:
#   - This is part of terragrunt tooling to ensure that only the correct AWS account is used to manage
#     the resources defined under this subdirectory.
#     The 'aws_account_id' can be added to the allowed list in the AWS provider to enforce this rule.

# Example:
#   https://github.com/gruntwork-io/terragrunt-infrastructure-live-example/blob/4a8569c33088e13938d412f65a27a16d4e2d524b/non-prod/account.hcl
#
# Set account-wide variables. These are automatically pulled in to configure the remote state bucket in the root
# terragrunt.hcl configuration.
locals {
  account_name   = "prod"
  aws_account_id = "PROD-ACCOUNT-CHANGEME"
  aws_profile    = "prod"
}
