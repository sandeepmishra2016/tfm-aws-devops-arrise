mock_provider "aws" {
  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }
}

run "plan_corrected_role_relationship" {
  command = plan

  assert {
    condition     = local.role_b_arn == "arn:aws:iam::000000000000:role/roleB"
    error_message = "roleC must trust roleB's role ARN."
  }

  assert {
    condition     = local.role_c_arn == "arn:aws:iam::111111111111:role/roleC"
    error_message = "roleB must be allowed to assume the exact roleC ARN."
  }

  assert {
    condition     = local.bucket_arn == "arn:aws:s3:::replace-with-account-b-bucket"
    error_message = "S3 permissions must be anchored to the named bucket."
  }
}
