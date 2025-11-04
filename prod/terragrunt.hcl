# Configure the remote state for all modules in the 'prod' environment.
remote_state {
  backend = "s3"
  config = {
    # Replace this with your actual, globally unique S3 bucket name for state
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

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "us-east-1"
  # Set desired AWS profile or roles here if not using environment variables
}
EOF
}
