terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = ">=4.33.0"
    }
  }
}
resource "cloudflare_record" "mail_from_mx" {
  zone_id  = var.zone_id
  name     = var.mail_from_subdomain
  type     = "MX"
  value    = "feedback-smtp.${var.aws_region}.amazonses.com"
  priority = 10
}

resource "cloudflare_record" "mail_from_spf" {
  zone_id = var.zone_id
  name    = var.mail_from_subdomain
  type    = "TXT"
  value   = "v=spf1 include:amazonses.com ~all"
}

resource "cloudflare_record" "easy_dkim" {
  count   = 3
  zone_id = var.zone_id
  name    = "${var.easy_dkim_tokens[count.index]}._domainkey"
  type    = "CNAME"
  value   = "${var.easy_dkim_tokens[count.index]}.dkim.amazonses.com"
  proxied = false
}
