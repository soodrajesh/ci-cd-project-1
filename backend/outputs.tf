output "tf_state_bucket_name" {
  value = aws_s3_bucket.terraform_state.id
}

output "tf_state_bucket_region" {
  value = aws_s3_bucket.terraform_state.region
}

output "tf_state_bucket_arn" {
  value = aws_s3_bucket.terraform_state.arn
}

output "tf_dynamodb_lock_table_name" {
  value = aws_dynamodb_table.terraform_state_lock.id
}

output "tf_dynamodb_lock_table_arn" {
  value = aws_dynamodb_table.terraform_state_lock.arn
}
