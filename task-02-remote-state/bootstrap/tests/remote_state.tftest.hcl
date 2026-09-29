mock_provider "aws" {
  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }
}

variables {
  aws_region        = "ap-south-1"
  state_bucket_name = "arrise-test-state-000000000000"
  lock_table_name   = "arrise-test-state-locks"
}

run "plan_secure_remote_state" {
  command = plan

  assert {
    condition     = aws_s3_bucket_versioning.terraform_state.versioning_configuration[0].status == "Enabled"
    error_message = "State bucket versioning must be enabled."
  }

  assert {
    condition = alltrue([
      for rule in aws_s3_bucket_server_side_encryption_configuration.terraform_state.rule :
      one(rule.apply_server_side_encryption_by_default).sse_algorithm == "AES256"
    ])
    error_message = "State bucket encryption must be enabled."
  }

  assert {
    condition = alltrue([
      aws_s3_bucket_public_access_block.terraform_state.block_public_acls,
      aws_s3_bucket_public_access_block.terraform_state.block_public_policy,
      aws_s3_bucket_public_access_block.terraform_state.ignore_public_acls,
      aws_s3_bucket_public_access_block.terraform_state.restrict_public_buckets
    ])
    error_message = "Every S3 public-access block setting must be enabled."
  }

  assert {
    condition     = aws_dynamodb_table.terraform_locks.hash_key == "LockID"
    error_message = "The lock table partition key must be LockID."
  }

  assert {
    condition     = aws_dynamodb_table.terraform_locks.billing_mode == "PAY_PER_REQUEST"
    error_message = "The low-throughput lock table should use on-demand billing."
  }
}
