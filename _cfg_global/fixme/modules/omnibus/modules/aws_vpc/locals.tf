locals {
  env = lower(var.env)

  meta_data = var.meta_data

  region = lower(var.region)

  # Flatten the config so that we can send parameters to external modules
  app_id = jsondecode(var.meta_data).app_id
  owner  = jsondecode(var.meta_data).owner

  tags = {
    Name   = "${local.app_id}-${local.owner}-${local.env}-${local.region}"
    App-ID = local.app_id,
    Owner  = local.owner,
    Env    = local.env,
    Region = local.region
  }

}
