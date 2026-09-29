output "state_bucket_name" {
  description = "S3 bucket to place in backend configuration."
  value       = aws_s3_bucket.terraform_state.id
}

output "lock_table_name" {
  description = "DynamoDB table to place in backend configuration."
  value       = aws_dynamodb_table.terraform_locks.name
}

