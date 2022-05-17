variable "env" {
  type = string

  validation {
    condition = anytrue([
      var.env == "dev",
      var.env == "tst",
      var.env == "stg",
      var.env == "prd"
    ])
    error_message = "Variable 'env' must be set to 'dev', 'tst', 'stg', or 'prd' ."
  }

}

variable "meta_data" {
  description = "App metadata"
  type        = string
}

variable "region" {
  description = "AWS Region name"
  type        = string

  validation {
    condition     = contains(["us-east-1", "us-east-2", "us-west-1", "us-west-2"], lower(var.region))
    error_message = "Error: invalid AWS Region."
  }

}

variable "aws_region_cfg" {
  description = "JSON-encoded config"
  type        = string

  validation {
    condition     = contains(keys(jsondecode(var.aws_region_cfg)), "vpc")
    error_message = "Error: every region must have a 'vpc = {}' section ."
  }
}
