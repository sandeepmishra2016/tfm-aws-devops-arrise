output "role_c_arn" {
  description = "Corrected roleC ARN."
  value       = aws_iam_role.role_c.arn
}

output "role_b_required_policy_json" {
  description = "Identity policy that must be attached to roleB in Account A."
  value       = data.aws_iam_policy_document.role_b_assume_role_c.json
}

