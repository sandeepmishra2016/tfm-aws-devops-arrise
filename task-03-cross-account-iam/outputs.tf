output "role_b_arn" {
  description = "Account A role that is trusted by roleC."
  value       = aws_iam_role.role_b.arn
}

output "role_c_arn" {
  description = "Account B role assumed by roleB."
  value       = aws_iam_role.role_c.arn
}
