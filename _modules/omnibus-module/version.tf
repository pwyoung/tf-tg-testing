terraform {
  required_version = ">= 1.1.4"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      #version = ">= 3.63"
      # https://registry.terraform.io/providers/hashicorp/aws/latest
      #version = "~> 4"
      version = ">= 4.13"
    }
  }
}
