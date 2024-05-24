output "validated_destination_address" {
  description = "The destination address. The value is populated only if the address is validated in Cloudflare, otherwise the module will fail. Reference this value in another resource to delay resource creation until the address is validated."
  value       = data.external.validated_destination_address.result.address
}
