data "aws_iam_policy_document" "role_c_trust" {
  provider = aws.account_b

  statement {
    sid     = "TrustOnlyAccountARoleB"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [local.role_b_arn]
    }
  }
}

resource "aws_iam_role" "role_c" {
  provider           = aws.account_b
  name               = var.role_c_name
  assume_role_policy = data.aws_iam_policy_document.role_c_trust.json
}

data "aws_iam_policy_document" "role_c_s3" {
  provider = aws.account_b

  statement {
    sid       = "FullAccessToNamedBucketOnly"
    effect    = "Allow"
    actions   = ["s3:*"]
    resources = local.role_c_s3_resources
  }
}

resource "aws_iam_role_policy" "role_c_s3" {
  provider = aws.account_b
  name     = "named-bucket-access"
  role     = aws_iam_role.role_c.id
  policy   = data.aws_iam_policy_document.role_c_s3.json
}
