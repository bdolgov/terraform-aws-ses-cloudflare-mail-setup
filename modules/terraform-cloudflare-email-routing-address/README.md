# Cloudflare Email Routing Destination (Blocking)

This module creates email routing destination address in the specified account and optionally waits
for the address verification.

It is useful to delay creation of other resources to the moment when a new address is verified --
for example, when creating an AWS SES identity for an address that is redirected to the to be
verified address.

## Waiting

Waiting is implemented using an external Bash script which polls Cloudflare API to get the address
validation status. The script requires:

* Being run in Linux-like environment with `bash`, `curl`, and `jq` installed.
* `CLOUDFLARE_API_TOKEN` envronment variable with the Cloudflare API token.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name                                                                         | Version  |
| ---------------------------------------------------------------------------- | -------- |
| <a name="requirement_cloudflare"></a> [cloudflare](#requirement\_cloudflare) | >=4.33.0 |
| <a name="requirement_external"></a> [external](#requirement\_external)       | >=2.3.3  |

## Providers

| Name                                                                   | Version  |
| ---------------------------------------------------------------------- | -------- |
| <a name="provider_cloudflare"></a> [cloudflare](#provider\_cloudflare) | >=4.33.0 |
| <a name="provider_external"></a> [external](#provider\_external)       | >=2.3.3  |

## Modules

No modules.

## Resources

| Name                                                                                                                                               | Type        |
| -------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [cloudflare_email_routing_address.this](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/email_routing_address) | resource    |
| [external_external.validated_destination_address](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external)    | data source |

## Inputs

| Name                                                                                                                            | Description                                                                                                                                                           | Type     | Default | Required |
| ------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | ------- | :------: |
| <a name="input_account_id"></a> [account\_id](#input\_account\_id)                                                              | Cloudflare acount ID to create the routing destination in.                                                                                                            | `string` | n/a     |   yes    |
| <a name="input_destination_address"></a> [destination\_address](#input\_destination\_address)                                   | Set of routing destinations to create.                                                                                                                                | `string` | n/a     |   yes    |
| <a name="input_wait_for_verification_timeout"></a> [wait\_for\_verification\_timeout](#input\_wait\_for\_verification\_timeout) | Number of seconds to wait for address to become verified in Cloudflare. If null, the module won't check anything and will return the destination address immediately. | `number` | `300`   |    no    |

## Outputs

| Name                                                                                                                            | Description                                                                                                                                                                                                                         |
| ------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| <a name="output_validated_destination_address"></a> [validated\_destination\_address](#output\_validated\_destination\_address) | The destination address. The value is populated only if the address is validated in Cloudflare, otherwise the module will fail. Reference this value in another resource to delay resource creation until the address is validated. |
<!-- END_TF_DOCS -->