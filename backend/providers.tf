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
  # NOTE: Comment the backend block if initializing the terraform for the first time.
  # Refer README.md .
  backend "s3" {
    key = "terraform.tfstate"
    encrypt = true
  }
}
