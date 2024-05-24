terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.51.0"
    }
  }
}

resource "aws_iam_user" "this" {
  name = var.name
}

data "aws_iam_policy_document" "this" {
  statement {
    actions   = ["ses:SendRawEmail"]
    resources = var.allowed_resource_arns
  }
}

resource "aws_iam_user_policy" "this" {
  user   = aws_iam_user.this.name
  policy = data.aws_iam_policy_document.this.json
}

# SMTP users correspond to access keys.
resource "aws_iam_access_key" "this" {
  user    = aws_iam_user.this.name
  pgp_key = var.pgp_key
}
