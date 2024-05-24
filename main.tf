terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.51.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = ">=4.33.0"
    }
  }
}

# Find Cloudflare Zone IDs for each domain that has redirects.
data "cloudflare_zone" "domain" {
  for_each = var.redirects

  name = each.key
}

# Enable email redirects for the zone.
# TODO: Enable CF DMARC management once it gets an API:
# https://developers.cloudflare.com/dmarc-management/.
resource "cloudflare_email_routing_settings" "domain" {
  for_each = data.cloudflare_zone.domain

  zone_id = each.value.id
  enabled = "true"
}

locals {
  # Set of unique email recipients.
  recipients = toset(flatten(concat(
    [for domain in values(var.redirects) : values(domain)], var.extra_recipients
  )))
}

# Register all recipient addresses in Cloudflare as email routing destinations.
module "email_routing_address" {
  for_each = local.recipients

  source = "./modules/terraform-cloudflare-email-routing-address"
  # Will fail if domains are spread across multiple accounts: it is not supported.
  account_id                    = one(toset([for zone in data.cloudflare_zone.domain : zone.account_id]))
  destination_address           = each.key
  wait_for_verification_timeout = var.wait_for_verification_timeout
}

locals {
  # Mapping from recipient email address to their sanitized versions: with non-alphanumeric symbols
  # replaced with `-`. Used to create per-recipient resource names in AWS.
  sanitized_recipients = {
    for address in local.recipients : address => replace(address, "/[^a-z0-9]/", "-")
  }
  # TODO: Check that there are no collisions in the sanitized names?
}

# For every recipient, create a configuration set which delivers falures to that recipient.
module "ses_sns_notification" {
  for_each = local.sanitized_recipients

  source               = "./modules/terraform-aws-ses-sns-notification"
  name                 = each.value
  notification_address = each.key
}

locals {
  # Maps address to a domain owning this address. Used to find Cloudflare zone to put a redirect
  # into, and to compute a MAIL FROM domain for an address.
  address_to_domain = merge(
    [for domain, redirects in var.redirects : {
      for address in keys(redirects) : "${address}@${domain}" => domain
    }]...
  )
}

locals {
  # Maps full address to the recipient. The flattened version of the redirects configuration.
  # Used to define redirects in Cloudflare, identities in AWS, and entity access restrictions for
  # SMTP accounts.
  flat_redirects = merge([for domain, redirects in var.redirects : {
    for address, recipient in redirects : "${address}@${domain}" => recipient
  }]...)
}

# Create redirects in Cloudflare.
resource "cloudflare_email_routing_rule" "address" {
  for_each = {
    for address, recipient in local.flat_redirects : address =>
    # The value of module.email_routing_address[dst].validated_destination_address is always equal
    # to dst, but it appears in Terraform only after the address is validated -- meaning that
    # there is a data dependency between the validation and this variable, so the redirect resource
    # won't be created before the address is validated. It is important at the later step when
    # creating SES identities, as during email identity creation SES sends a verification message,
    # which will be delivered using this redirect, which requires a validated recipient address for
    # the successful delivery.
    module.email_routing_address[recipient].validated_destination_address
  }

  zone_id  = data.cloudflare_zone.domain[local.address_to_domain[each.key]].id
  name     = "Route ${each.key} to ${each.value}"
  priority = 0
  enabled  = true
  matcher {
    field = "to"
    type  = "literal"
    value = each.key
  }
  action {
    type  = "forward"
    value = [each.value]
  }
}

# Create AWS SES identities and their configs.
resource "aws_sesv2_email_identity" "address" {
  for_each = local.flat_redirects

  # Creating an email identity sends a verification message, which must be delivered though the
  # Cloudflare redirect.
  # TODO: Is there a way to depend on a specific rouing rule, not on all of them?
  depends_on             = [cloudflare_email_routing_rule.address]
  email_identity         = each.key
  configuration_set_name = module.ses_sns_notification[each.value].configuration_set_name
}

resource "aws_sesv2_email_identity" "domain" {
  for_each = toset(keys(var.redirects))

  email_identity = each.key
}

resource "aws_sesv2_email_identity_feedback_attributes" "identity" {
  for_each = merge(aws_sesv2_email_identity.address, aws_sesv2_email_identity.domain)

  email_identity           = each.value.email_identity
  email_forwarding_enabled = true
}

resource "aws_sesv2_email_identity_mail_from_attributes" "address" {
  for_each = aws_sesv2_email_identity.address

  email_identity         = each.value.email_identity
  behavior_on_mx_failure = "USE_DEFAULT_VALUE"
  mail_from_domain       = "${var.mail_from_subdomain}.${local.address_to_domain[each.key]}"
}

resource "aws_sesv2_email_identity_mail_from_attributes" "domain" {
  for_each = aws_sesv2_email_identity.domain

  email_identity         = each.value.email_identity
  behavior_on_mx_failure = "USE_DEFAULT_VALUE"
  mail_from_domain       = "${var.mail_from_subdomain}.${each.value.email_identity}"
}

# Find the current AWS region.
data "aws_region" "current" {}

# Insert DNS records to validate ownership over the domain identities in SES.
module "dns_records" {
  for_each = data.cloudflare_zone.domain

  source           = "./modules/terraform-cloudflare-aws-ses-records"
  zone_id          = each.value.id
  aws_region       = data.aws_region.current.name
  easy_dkim_tokens = aws_sesv2_email_identity.domain[each.key].dkim_signing_attributes[0].tokens
}

# For every recipient, create SMTP credentials that can send mail on behalf of every address that
# redirects to this recipient using their corresponding configuratiion set.
module "smtp_user" {
  for_each = local.sanitized_recipients

  source = "./modules/terraform-aws-ses-restricted-smtp-user"
  allowed_resource_arns = concat(
    [module.ses_sns_notification[each.key].configuration_set_arn],
    [for address, recipient in local.flat_redirects :
    aws_sesv2_email_identity.address[address].arn if recipient == each.key]
  )
  name    = "smtp-for-${each.value}"
  pgp_key = var.pgp_key
}
