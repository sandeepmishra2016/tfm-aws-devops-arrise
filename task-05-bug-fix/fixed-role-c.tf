locals {
  role_b_arn = "arn:aws:iam::${var.account_a_id}:role/${var.role_b_name}"
  role_c_arn = "arn:aws:iam::${var.account_b_id}:role/${var.role_c_name}"
  bucket_arn = "arn:aws:s3:::${var.bucket_name}"
}

data "aws_iam_policy_document" "role_c_trust" {
  statement {
    sid     = "TrustOnlyRoleB"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [local.role_b_arn]
    }
  }
}

resource "aws_iam_role" "role_c" {
  name               = var.role_c_name
  assume_role_policy = data.aws_iam_policy_document.role_c_trust.json
}

data "aws_iam_policy_document" "role_c_s3" {
  statement {
    sid     = "NamedBucketOnly"
    effect  = "Allow"
    actions = ["s3:*"]
    resources = [
      local.bucket_arn,
      "${local.bucket_arn}/*"
    ]
  }
}

resource "aws_iam_role_policy" "role_c_s3" {
  name   = "named-bucket-access"
  role   = aws_iam_role.role_c.id
  policy = data.aws_iam_policy_document.role_c_s3.json
}

# This identity policy belongs on roleB in Account A. This task renders the
# document only; deployment requires the Account A provider configuration.
data "aws_iam_policy_document" "role_b_assume_role_c" {
  statement {
    sid       = "AssumeOnlyRoleC"
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = [local.role_c_arn]
  }
}
