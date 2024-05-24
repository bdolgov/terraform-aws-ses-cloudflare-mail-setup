# Email Redirects Setup with Cloudflare and AWS SES

This module accepts the description of mail redirects, and configures Cloudflare Mail Routing for
incoming mail and AWS SES for outgoing mail.

The setup is described in detail here: [https://bdolgov.blog/b/custom-email-domain-using-gmail/].

[https://bdolgov.blog/b/custom-email-domain-using-gmail/]: https://bdolgov.blog/b/custom-email-domain-using-gmail/

## Resulting Setup

The module creates the following resources:

* For every configured domain:
  * Enables Cloudflare Mail Routing.
  * Creates an AWS SES identity.
  * Verifies the identity ownership in AWS SES by creating required DNS records in Cloudflare.
  * Configures the AWS SES identity to use a custom MAIL FROM domain and creates required records in
    Cloudflare.
* For every configured redirect address:
  * Creates a Cloudflare mail redirect from the address to the specified recipient.
  * Creates an AWS SES identity.
* For every unique configured recipient (meaining: redirect target):
  * Creates an AWS SES configuration set, sets it as default for all identities that are redirecting
    to the recipient, and configures SNS email notifications about failures in this configuration
    set.
  * Creates an AWS IAM user, restricts it to entities that are redirecting to the recipient, creates
    and access key, and outputs SMTP credentials associated with the key.

## Usage

A minimal example `main.tf`:

```terraform
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.51"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = ">= 4.33"
    }
  }
}

provider "aws" { region = "eu-north-1" }
provider "cloudflare" {}

module "mail_setup" {
  source = "github.com/bdolgov/terraform-aws-ses-cloudflare-mail-setup"
  redirects = {
    "foo.com" = {
      "admin" = "someone@gmail.com",  # Redirect admin@foo.com to someone@gmail.com.
      "postmaster" = "someone@gmail.com",  # Redirect postmaster@foo.com to someone@gmail.com.
    },
    "yourlast.name" = {
      "alex" = "someone-else@gmail.com",  # Redirect alex@yourlast.name to someone-else@gmail.com.
      "boris" = "someone@gmail.com",  # Redirect boris@yourlastname.com to someone@gmail.com.
    },
  }
  pgp_key = "<gpg --export | base64 -w0>"
}

output "smtp_accounts" {
  value     = module.mail_setup.smtp_accounts
  sensitive = true
}
```

Put `CLOUDFLARE_API_TOKEN`, `AWS_ACCESS_KEY_ID`, and `AWS_SECRET_ACCESS_KEY` into environment
variables, and run `terraform init && terraform apply && terraform output -json smtp_accounts | jq`.

The module will output SMTP credentials for all recipients:

```json
{
  "someone@gmail.com": {
    "encrypted_password": "...",
    "password": null,
    "username": "AKIA..."
  },
  "someone=else@gmail.com": {
    "encrypted_password": "...",
    "password": null,
    "username": "AKIA..."
  },
}
```

For more information about encrypted SMTP passwords, see
[modules/terraform-aws-ses-restricted-smtp-user/](modules/terraform-aws-ses-restricted-smtp-user/).

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name                                                                         | Version  |
| ---------------------------------------------------------------------------- | -------- |
| <a name="requirement_aws"></a> [aws](#requirement\_aws)                      | >=5.51.0 |
| <a name="requirement_cloudflare"></a> [cloudflare](#requirement\_cloudflare) | >=4.33.0 |

## Providers

| Name                                                                   | Version |
| ---------------------------------------------------------------------- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws)                      | 5.50.0  |
| <a name="provider_cloudflare"></a> [cloudflare](#provider\_cloudflare) | 4.33.0  |

## Modules

| Name                                                                                                    | Source                                               | Version |
| ------------------------------------------------------------------------------------------------------- | ---------------------------------------------------- | ------- |
| <a name="module_dns_records"></a> [dns\_records](#module\_dns\_records)                                 | ./modules/terraform-cloudflare-aws-ses-records       | n/a     |
| <a name="module_email_routing_address"></a> [email\_routing\_address](#module\_email\_routing\_address) | ./modules/terraform-cloudflare-email-routing-address | n/a     |
| <a name="module_ses_sns_notification"></a> [ses\_sns\_notification](#module\_ses\_sns\_notification)    | ./modules/terraform-aws-ses-sns-notification         | n/a     |
| <a name="module_smtp_user"></a> [smtp\_user](#module\_smtp\_user)                                       | ./modules/terraform-aws-ses-restricted-smtp-user     | n/a     |

## Resources

| Name                                                                                                                                                                           | Type        |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ----------- |
| [aws_sesv2_email_identity.address](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sesv2_email_identity)                                           | resource    |
| [aws_sesv2_email_identity.domain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sesv2_email_identity)                                            | resource    |
| [aws_sesv2_email_identity_feedback_attributes.identity](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sesv2_email_identity_feedback_attributes)  | resource    |
| [aws_sesv2_email_identity_mail_from_attributes.address](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sesv2_email_identity_mail_from_attributes) | resource    |
| [aws_sesv2_email_identity_mail_from_attributes.domain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sesv2_email_identity_mail_from_attributes)  | resource    |
| [cloudflare_email_routing_rule.address](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/email_routing_rule)                                | resource    |
| [cloudflare_email_routing_settings.domain](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/email_routing_settings)                         | resource    |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region)                                                                    | data source |
| [cloudflare_zone.domain](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/data-sources/zone)                                                          | data source |

## Inputs

| Name                                                                                                                            | Description                                                                                                                                                                                                                                                                                                        | Type               | Default  | Required |
| ------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------ | -------- | :------: |
| <a name="input_extra_recipients"></a> [extra\_recipients](#input\_extra\_recipients)                                            | Extra recipients which will have SMTP accounts and configuration sets always created for them, even if there are no addresses redirecting to them. Use it to temporarily remove or change a redirect without forcing the config to remove the SMTP account for the recipient.                                      | `list(string)`     | `[]`     |    no    |
| <a name="input_mail_from_subdomain"></a> [mail\_from\_subdomain](#input\_mail\_from\_subdomain)                                 | MAIL FROM subdomain to configure in SES (instead of amazonses.com). Currently mandatory.                                                                                                                                                                                                                           | `string`           | `"mail"` |    no    |
| <a name="input_pgp_key"></a> [pgp\_key](#input\_pgp\_key)                                                                       | PGP key to encrypt the password with. If unset, plaintext password will be in the outputs.                                                                                                                                                                                                                         | `string`           | `null`   |    no    |
| <a name="input_redirects"></a> [redirects](#input\_redirects)                                                                   | Mapping from domain name to a mapping of addresses in this domain to recipient addresses.                                                                                                                                                                                                                          | `map(map(string))` | n/a      |   yes    |
| <a name="input_wait_for_verification_timeout"></a> [wait\_for\_verification\_timeout](#input\_wait\_for\_verification\_timeout) | Number of seconds to wait for recipient addresses to become verified in Cloudflare. If not null, the module will block creation of redirects and AWS SES entities until the recipient address is verified. This is useful to ensure that the initial SES verification email gets delivered using the new redirect. | `number`           | `300`    |    no    |

## Outputs

| Name                                                                          | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| ----------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| <a name="output_smtp_accounts"></a> [smtp\_accounts](#output\_smtp\_accounts) | The list of SMTP accounts that the module creates: one account per unique mail recipient. Mapping from recipient email address to their SMTP account credentials, which is an object containing `username`, `password`, and `encrypted_password` fields. `password` is not null only if `var.pgp_key` is null, and `encrypted_password` is not null only if `var.pgp_key` is not null. `encrypted_password` is a base64-encoded PGP-encrypted password, use `base64 -d` and `pgp --decrypt` to decrypt. |
<!-- END_TF_DOCS -->