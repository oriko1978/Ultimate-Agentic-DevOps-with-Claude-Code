# Remote state backend (S3)
#
# Bootstrap order:
#   1. Leave this block commented out and run `terraform init` — state is stored locally.
#   2. Run `terraform apply` to create the resources.
#   3. Create an S3 bucket for Terraform state (versioning enabled, public access blocked).
#   4. Uncomment the block below, fill in the bucket name/region, and run:
#        terraform init -migrate-state
#      Terraform will copy the local state into the S3 backend.
#
# `use_lockfile` enables native S3 state locking (Terraform >= 1.10); on older
# versions, remove it and use a DynamoDB table via `dynamodb_table` instead.

# terraform {
#   backend "s3" {
#     bucket       = "oriko-project-terraform-state"
#     key          = "oriko-project/production/terraform.tfstate"
#     region       = "eu-north-1"
#     encrypt      = true
#     use_lockfile = true
#   }
# }
