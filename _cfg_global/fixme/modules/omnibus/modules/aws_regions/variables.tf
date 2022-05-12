variable "env" {
  type = string

  validation {
    condition = anytrue([
      var.env == "development",
      var.env == "test",
      var.env == "staging",
      var.env == "production"
    ])
    error_message = "Variable 'env' must be set to 'development', 'test', 'staging', or 'production' ."
  }

}

variable "meta_data" {
  description = "App metadata"
  type        = string
}

variable "aws_regions_cfg" {
  description = "JSON-encoded config"
  type        = string

  # This works, but the code has no such limitation
  #validation {
  #  condition = length( jsondecode(var.aws_regions_cfg) ) <= 3
  #  error_message = "Error: the number of AWS Regions must be 3 or less."
  #}

  # This works, but if we let the error be reported downstream,
  # then the user will see the name of the problematic region
  #validation {
  #  condition = ! contains([for s in keys (jsondecode(var.aws_regions_cfg)) : contains(["us-east-1","us-east-2","us-west-1","us-west-2","FOO"], lower(s)) ? "y" : "n"], "n")
  #  error_message = "Error: invalid AWS Region."
  #}

}

