variable "redirects" {
  description = "Mapping from domain name to a mapping of addresses in this domain to recipient addresses."
  type        = map(map(string))
  nullable    = false
}
variable "mail_from_subdomain" {
  description = "MAIL FROM subdomain to configure in SES (instead of amazonses.com). Currently mandatory."
  type        = string
  default     = "mail"
  nullable    = false
}
variable "pgp_key" {
  description = "PGP key to encrypt the password with. If unset, plaintext password will be in the outputs."
  type        = string
  default     = null
}
variable "extra_recipients" {
  description = "Extra recipients which will have SMTP accounts and configuration sets always created for them, even if there are no addresses redirecting to them. Use it to temporarily remove or change a redirect without forcing the config to remove the SMTP account for the recipient."
  type        = list(string)
  default     = []
}
variable "wait_for_verification_timeout" {
  description = "Number of seconds to wait for recipient addresses to become verified in Cloudflare. If not null, the module will block creation of redirects and AWS SES entities until the recipient address is verified. This is useful to ensure that the initial SES verification email gets delivered using the new redirect."
  type        = number
  default     = 300
}
