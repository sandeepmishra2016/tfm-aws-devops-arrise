mock_provider "aws" {
  alias = "account_a"

  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }
}

mock_provider "aws" {
  alias = "account_b"

  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }
}

run "plan_exact_cross_account_boundary" {
  command = plan

  assert {
    condition     = local.role_b_arn == "arn:aws:iam::000000000000:role/roleB"
    error_message = "roleB must be represented by its role ARN, not a user or account-root ARN."
  }

  assert {
    condition     = local.role_c_arn == "arn:aws:iam::111111111111:role/roleC"
    error_message = "roleB must target the exact Account B roleC ARN."
  }

  assert {
    condition     = length(aws_iam_user.users) == 4
    error_message = "Exactly four requested IAM users should be modelled."
  }

  assert {
    condition     = toset(aws_iam_group_membership.group1.users) == toset(["engine", "ci"])
    error_message = "group1 must contain engine and ci only."
  }

  assert {
    condition     = length(aws_iam_access_key.legacy) == 0
    error_message = "Long-lived access keys must remain disabled by default."
  }

  assert {
    condition     = local.bucket_arn == "arn:aws:s3:::replace-with-account-b-bucket"
    error_message = "roleC S3 access must be anchored to one named bucket ARN."
  }

  assert {
    condition     = local.role_b_actions == ["sts:AssumeRole"]
    error_message = "roleB must not receive permissions beyond assuming roleC."
  }

  assert {
    condition = toset(local.role_c_s3_resources) == toset([
      "arn:aws:s3:::replace-with-account-b-bucket",
      "arn:aws:s3:::replace-with-account-b-bucket/*"
    ])
    error_message = "roleC S3 access must include only the named bucket and its objects."
  }
}
