locals {
  cli_user_names     = toset(["engine", "ci"])
  console_user_names = toset(["operations-admin-1", "operations-admin-2"])
  all_user_names     = setunion(local.cli_user_names, local.console_user_names)

  role_b_arn = "arn:aws:iam::${var.account_a_id}:role/${var.role_b_name}"
  role_c_arn = "arn:aws:iam::${var.account_b_id}:role/${var.role_c_name}"
  bucket_arn = "arn:aws:s3:::${var.account_b_bucket_name}"
}

