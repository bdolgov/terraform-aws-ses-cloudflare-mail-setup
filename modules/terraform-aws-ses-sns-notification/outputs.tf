output "configuration_set_name" {
  description = "Configuration set name."
  value       = aws_sesv2_configuration_set.this.configuration_set_name
}
output "configuration_set_arn" {
  description = "Configuration set ARN."
  value       = aws_sesv2_configuration_set.this.arn
}
