output "ci_policy_arn" {
  description = "ARN of the generated least-privilege policy."
  value       = aws_iam_policy.ci.arn
}

output "ci_policy_json" {
  description = "Rendered policy JSON for reviewer inspection."
  value       = data.aws_iam_policy_document.ci.json
}

