variable "account_id" {
  description = "Cloudflare acount ID to create the routing destination in."
  type        = string
  nullable    = false
}
variable "destination_address" {
  description = "Set of routing destinations to create."
  type        = string
  nullable    = false
}
variable "wait_for_verification_timeout" {
  description = "Number of seconds to wait for address to become verified in Cloudflare. If null, the module won't check anything and will return the destination address immediately."
  type        = number
  default     = 300
  nullable    = true
}
