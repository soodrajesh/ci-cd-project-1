provider "aws" {
  region  = var.region
  profile = var.profile
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  backend "s3" {
    bucket = "demo-tf-state"
    key = "global/tfstate/terraform.tfstate"
    encrypt = true
    dynamodb_table = "demo-tf-state-lock"
    region  = var.region
}