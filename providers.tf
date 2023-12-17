terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
      region = "us-west-2"
    }
  }

  backend "s3" {
    bucket = "demo-tf-state"
    key = "global/tfstate/terraform.tfstate"
    encrypt = true
    dynamodb_table = "demo-tf-state-lock"
    }
  }