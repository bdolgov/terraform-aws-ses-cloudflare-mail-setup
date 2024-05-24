output "smtp_username" {
  description = "SMTP username."
  value       = aws_iam_access_key.this.id
}
output "smtp_password" {
  description = "Plain text SMTP password. Null if var.pgp_key is set."
  value       = aws_iam_access_key.this.ses_smtp_password_v4
  sensitive   = true
}
output "encrypted_smtp_password" {
  description = "Encrypted password in base64, to be decrypted with `gpg --decrypt`. Null if `var.pgp_key` is not set."
  value       = aws_iam_access_key.this.encrypted_ses_smtp_password_v4
}
