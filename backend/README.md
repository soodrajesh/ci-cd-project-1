# Terraform backend
Setup backend for all deployments.

## Usage
* :warning: When creating the backend for the first time, comment the `backend` block in the `providers.tf` file. 
  * This is done because the S3 bucket & DynamoDB table for Terraform state needs to be created first, then we can use that as backend.
* Steps:
  * Comment the backend block
  * Run `terraform init`, this will use the default `local` backend.
  * Run `terraform apply -var-file=../config.tfbackend`, to create the S3 bucket & DynamoDB table.
  * Uncomment the backend block.
  * Run `terraform init -backend-config=../config.tfbackend`, to copy the state to the S3 bucket.
  * Run `terraform apply -var-file=../config.tfbackend`, and it should show no changes.
