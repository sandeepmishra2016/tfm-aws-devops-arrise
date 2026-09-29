output "role_b_arn" {
  description = "Account A role that is trusted by roleC."
  value       = aws_iam_role.role_b.arn
}

output "role_c_arn" {
  description = "Account B role assumed by roleB."
  value       = aws_iam_role.role_c.arn
}

output "legacy_encrypted_access_key_secrets" {
  description = "PGP-encrypted access-key secrets when legacy credential creation is explicitly enabled."
  value       = { for name, key in aws_iam_access_key.legacy : name => key.encrypted_secret }
  sensitive   = true
}

output "legacy_encrypted_console_passwords" {
  description = "PGP-encrypted console passwords when legacy credential creation is explicitly enabled."
  value       = { for name, profile in aws_iam_user_login_profile.legacy_console : name => profile.encrypted_password }
  sensitive   = true
}

