# Include the root configuration for remote state and providers
include "root" {
  path = "../terragrunt.hcl"
}

# Specify the module to be used
terraform {
  source = "../../modules/Static-side-cdn"
}

# Define the variable values for this specific deployment
inputs = {
  bucket_name = "checkpoint-assignment-prod"
  tags = {
    Name      = "Productcloudfront"
    Owner     = "pradeep yadav"
    Environment = "Production"
    Terraform = true
  }
}
