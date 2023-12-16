variable "profile" {
  type = string
  default = "default"
  description = "The AWS profile to use."
}

variable "region" {
  type = string
  description = "The region we are deploying to."
}

variable "bucket" {
  type = string
  description = "The bucket name to use for terraform backend."
}

variable "dynamodb_table" {
  type = string
  description = "The dynamodb table to use for terraform backend."
}
