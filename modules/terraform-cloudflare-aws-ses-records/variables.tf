variable "zone_id" {
  description = "Zone ID in Cloudflare."
  type        = string
  nullable    = false
}
variable "mail_from_subdomain" {
  description = "MAIL FROM subdomain name. Should not include the domain name."
  type        = string
  default     = "mail"
  nullable    = false
}
variable "easy_dkim_tokens" {
  description = "Easy DKIM tokens, typically from aws_sesv2_email_identity resource: `aws_sesv2_email_identity.identity.dkim_signing_attributes[0].tokens`. Must be a list with 3 items."
  type        = list(string)
  nullable    = false
}
variable "aws_region" {
  description = "Amazon region name. Passed externally instead of reading from `data.aws_region.current` to avoid a dependency on the AWS provider in this module."
  type        = string
  nullable    = false
}
