data "aws_iam_policy_document" "role_a_trust" {
  provider = aws.account_a

  statement {
    sid     = "AllowNamedAdministrators"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type = "AWS"
      identifiers = [
        for user_name in sort(tolist(local.console_user_names)) :
        "arn:aws:iam::${var.account_a_id}:user/${user_name}"
      ]
    }

    condition {
      test     = "Bool"
      variable = "aws:MultiFactorAuthPresent"
      values   = ["true"]
    }
  }
}

resource "aws_iam_role" "role_a" {
  provider           = aws.account_a
  name               = var.role_a_name
  assume_role_policy = data.aws_iam_policy_document.role_a_trust.json
}

data "aws_iam_policy_document" "role_a_permissions" {
  provider = aws.account_a

  statement {
    sid       = "AllowAdministration"
    effect    = "Allow"
    actions   = ["*"]
    resources = ["*"]
  }

  statement {
    sid       = "DenyIAMAdministration"
    effect    = "Deny"
    actions   = ["iam:*"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "role_a" {
  provider = aws.account_a
  name     = "administration-except-iam"
  role     = aws_iam_role.role_a.id
  policy   = data.aws_iam_policy_document.role_a_permissions.json
}

data "aws_iam_policy_document" "group2_assume_role_a" {
  provider = aws.account_a

  statement {
    sid       = "AssumeRoleA"
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = ["arn:aws:iam::${var.account_a_id}:role/${var.role_a_name}"]
  }
}

resource "aws_iam_group_policy" "group2_assume_role_a" {
  provider = aws.account_a
  name     = "assume-role-a"
  group    = aws_iam_group.group2.name
  policy   = data.aws_iam_policy_document.group2_assume_role_a.json
}

data "aws_iam_policy_document" "role_b_trust" {
  provider = aws.account_a

  statement {
    sid     = "AllowNamedCLIUsers"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type = "AWS"
      identifiers = [
        for user_name in sort(tolist(local.cli_user_names)) :
        "arn:aws:iam::${var.account_a_id}:user/${user_name}"
      ]
    }
  }
}

resource "aws_iam_role" "role_b" {
  provider           = aws.account_a
  name               = var.role_b_name
  assume_role_policy = data.aws_iam_policy_document.role_b_trust.json
}

data "aws_iam_policy_document" "role_b_permissions" {
  provider = aws.account_a

  statement {
    sid       = "AssumeOnlyRoleC"
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = [local.role_c_arn]
  }
}

resource "aws_iam_role_policy" "role_b" {
  provider = aws.account_a
  name     = "assume-role-c-only"
  role     = aws_iam_role.role_b.id
  policy   = data.aws_iam_policy_document.role_b_permissions.json
}

data "aws_iam_policy_document" "group1_assume_role_b" {
  provider = aws.account_a

  statement {
    sid       = "AssumeRoleB"
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = [local.role_b_arn]
  }
}

resource "aws_iam_group_policy" "group1_assume_role_b" {
  provider = aws.account_a
  name     = "assume-role-b"
  group    = aws_iam_group.group1.name
  policy   = data.aws_iam_policy_document.group1_assume_role_b.json
}
