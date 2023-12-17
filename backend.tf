terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  backend "s3" {
    bucket         = "demo-tf-state-rsood"
    key            = "global/tfstate/terraform.tfstate"
    encrypt        = true
    dynamodb_table = "demo-tf-state-lock"
    region         = "us-west-2"
  }
}
