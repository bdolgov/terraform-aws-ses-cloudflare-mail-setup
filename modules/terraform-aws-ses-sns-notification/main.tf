terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.51.0"
    }
  }
}

resource "aws_sesv2_configuration_set" "this" {
  configuration_set_name = var.name
}

# TODO: Create a more restricted ACL for the topic?
resource "aws_sns_topic" "this" {
  name         = "ses-${var.name}"
  display_name = "SES Notifications for ${var.name}"
}

resource "aws_sns_topic_subscription" "this" {
  topic_arn = aws_sns_topic.this.arn
  protocol  = "email"
  endpoint  = var.notification_address
}

resource "aws_sesv2_configuration_set_event_destination" "this" {
  configuration_set_name = aws_sesv2_configuration_set.this.configuration_set_name
  event_destination_name = aws_sns_topic.this.name
  event_destination {
    sns_destination {
      topic_arn = aws_sns_topic.this.arn
    }
    matching_event_types = var.event_types
    enabled              = true
  }
}

