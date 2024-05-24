output "smtp_accounts" {
  description = "The list of SMTP accounts that the module creates: one account per unique mail recipient. Mapping from recipient email address to their SMTP account credentials, which is an object containing `username`, `password`, and `encrypted_password` fields. `password` is not null only if `var.pgp_key` is null, and `encrypted_password` is not null only if `var.pgp_key` is not null. `encrypted_password` is a base64-encoded PGP-encrypted password, use `base64 -d` and `pgp --decrypt` to decrypt."
  value = {
    for recipient, smtp_user in module.smtp_user :
    recipient => {
      username           = smtp_user.smtp_username,
      password           = smtp_user.smtp_password,
      encrypted_password = smtp_user.encrypted_smtp_password,
    }
  }
  sensitive = true
}
