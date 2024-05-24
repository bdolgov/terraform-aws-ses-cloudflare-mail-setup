terraform {
  required_providers {
    external = {
      source  = "hashicorp/external"
      version = ">=2.3.3"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = ">=4.33.0"
    }
  }
}

resource "cloudflare_email_routing_address" "this" {
  account_id = var.account_id
  email      = var.destination_address
}

data "external" "validated_destination_address" {
  # TODO: Not invoke the script at all, if timeout is disabled?
  program = ["bash", "${path.module}/wait_for_verification.sh"]
  query = {
    timeout    = var.wait_for_verification_timeout
    account_id = cloudflare_email_routing_address.this.account_id
    id         = cloudflare_email_routing_address.this.id
    address    = cloudflare_email_routing_address.this.email
  }
}
