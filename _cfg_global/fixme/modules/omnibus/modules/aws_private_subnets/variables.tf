variable "tags" {}
variable "vpc_id" {}
variable "private_subnet_cidrs" {}
variable "azs" {}
variable "private_inbound_acl_rules" {}
variable "private_outbound_acl_rules" {}
variable "public_subnet_ids" {
  # TODO: consider adding a Terraform Variable Validation to assert
  #       there are at least as many public subnets as private subnets
}
