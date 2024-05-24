variable "name" {
  description = "User name. It will be visible in AWS console and in error messages, but not anywhere else."
  type        = string
  nullable    = false
}
variable "allowed_resource_arns" {
  description = "List of allowed resources for the user. Must include the email or domain identity and identity's default configuration set, if it is set."
  type        = list(string)
}
variable "pgp_key" {
  description = "PGP key to encrypt the password with. If unset, plaintext password will be in the outputs."
  type        = string
  default     = null
}
