# Configure Terragrunt to automatically retry on errors and apply the specified configurations
terraform {
  extra_arguments "init_args" {
    commands = [
      "init"
    ]
  }
}

# Configure the remote state for all modules in the 'prod' environment.
remote_state {
  backend = "s3"
  config = {
    bucket         = "production-terraform-state-eu-north-1"
    key            = "prod/${path_relative_to_include()}/terraform.tfstate"
    region         = "eu-north-1"
    encrypt        = true
    dynamodb_table = "terraform-lock-table"
  }

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}
