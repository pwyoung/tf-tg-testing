# Purpose

Terraform-related code goes under here.

The top-level terragrunt.hcl file is here so that it can be found
and serve as a base path for finding other things.

This allows us to support global/common settings.

The most important of these is the common remote (S3/Dyanmo)
backend for the whole project.
