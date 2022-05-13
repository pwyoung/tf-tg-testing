# GOAL
This is the root module for the code that handles
the general-purpose config file such as:

 cfg = jsonencode(
    {
      # ENVIRONMENT
      env = "dev"

      # APP COMMON META-DATA
      meta_data = {
        app_id    = "connectivitytesting"
        owner = "pwy"
      }

      # AWS
      aws = {
        regions = {
          "us-east-1" = {
            vpc = {
              vpc_cidr_block        = "10.100.0.0/16",
              secondary_cidr_blocks = []
              public_subnets        = ["10.100.101.0/24", "10.100.102.0/24", "10.100.103.0/24"]
              private_subnets       = ["10.100.201.0/24"]
            }
          }
...
