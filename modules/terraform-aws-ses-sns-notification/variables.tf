variable "name" {
  description = "Configuration set name. The topic name will be derived from it."
  type        = string
  nullable    = false
}
variable "notification_address" {
  description = "Email address to send notifications to."
  type        = string
  nullable    = false
}
variable "event_types" {
  description = "Types of events to subscribe for. Defaults to problematic events."
  type        = list(string)
  default     = ["BOUNCE", "COMPLAINT", "DELIVERY_DELAY", "REJECT", "SUBSCRIPTION"]
  nullable    = false
}
