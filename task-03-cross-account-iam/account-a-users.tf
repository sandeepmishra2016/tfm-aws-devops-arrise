resource "aws_iam_user" "users" {
  provider = aws.account_a
  for_each = local.all_user_names

  name          = each.key
  force_destroy = false
}

resource "aws_iam_group" "group1" {
  provider = aws.account_a
  name     = "group1"
}

resource "aws_iam_group" "group2" {
  provider = aws.account_a
  name     = "group2"
}

resource "aws_iam_group_membership" "group1" {
  provider = aws.account_a
  name     = "group1-membership"
  group    = aws_iam_group.group1.name
  users    = [for user_name in sort(tolist(local.cli_user_names)) : aws_iam_user.users[user_name].name]
}

resource "aws_iam_group_membership" "group2" {
  provider = aws.account_a
  name     = "group2-membership"
  group    = aws_iam_group.group2.name
  users    = [for user_name in sort(tolist(local.console_user_names)) : aws_iam_user.users[user_name].name]
}

resource "aws_iam_access_key" "legacy" {
  provider = aws.account_a
  for_each = var.create_legacy_credentials ? local.all_user_names : toset([])

  user    = aws_iam_user.users[each.key].name
  pgp_key = var.user_pgp_keys[each.key]
}

resource "aws_iam_user_login_profile" "legacy_console" {
  provider = aws.account_a
  for_each = var.create_legacy_credentials ? local.console_user_names : toset([])

  user                    = aws_iam_user.users[each.key].name
  pgp_key                 = var.user_pgp_keys[each.key]
  password_reset_required = true
}

