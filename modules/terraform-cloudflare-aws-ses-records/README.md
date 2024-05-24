# Cloudflare DNS Records for SESv2 Domain Identity

Creates 
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name                                                                         | Version  |
| ---------------------------------------------------------------------------- | -------- |
| <a name="requirement_cloudflare"></a> [cloudflare](#requirement\_cloudflare) | >=4.33.0 |

## Providers

| Name                                                                   | Version  |
| ---------------------------------------------------------------------- | -------- |
| <a name="provider_cloudflare"></a> [cloudflare](#provider\_cloudflare) | >=4.33.0 |

## Modules

No modules.

## Resources

| Name                                                                                                                          | Type     |
| ----------------------------------------------------------------------------------------------------------------------------- | -------- |
| [cloudflare_record.easy_dkim](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record)     | resource |
| [cloudflare_record.mail_from_mx](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record)  | resource |
| [cloudflare_record.mail_from_spf](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record) | resource |

## Inputs

| Name                                                                                            | Description                                                                                                                                                                | Type           | Default  | Required |
| ----------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------- | -------- | :------: |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region)                              | Amazon region name. Passed externally instead of reading from `data.aws_region.current` to avoid a dependency on the AWS provider in this module.                          | `string`       | n/a      |   yes    |
| <a name="input_easy_dkim_tokens"></a> [easy\_dkim\_tokens](#input\_easy\_dkim\_tokens)          | Easy DKIM tokens, typically from aws\_sesv2\_email\_identity resource: `aws_sesv2_email_identity.identity.dkim_signing_attributes[0].tokens`. Must be a list with 3 items. | `list(string)` | n/a      |   yes    |
| <a name="input_mail_from_subdomain"></a> [mail\_from\_subdomain](#input\_mail\_from\_subdomain) | MAIL FROM subdomain name. Should not include the domain name.                                                                                                              | `string`       | `"mail"` |    no    |
| <a name="input_zone_id"></a> [zone\_id](#input\_zone\_id)                                       | Zone ID in Cloudflare.                                                                                                                                                     | `string`       | n/a      |   yes    |

## Outputs

No outputs.
<!-- END_TF_DOCS -->