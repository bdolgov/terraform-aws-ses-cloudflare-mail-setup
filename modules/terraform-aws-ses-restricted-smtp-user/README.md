# AWS SES SMTP User Creation

Creates an AWS IAM user, attaches a policy allowing it to use AWS SES SMTP, and outputs SMTP
username and password.

## Password Encryption

To avoid storing plaintext passwords in the state, AWS supports PGP encryption of passwords. To use
it:

1. (If you haven't already), Generate a PGP key: `gpg --gen-key`.
2. Export the public part to base64 (without `--armor`): `gpg --export | base64 -w0`.
3. Put the public key into the `pgp_key` variable.
4. Get the output and decrypt the password: `terraform output -raw encrypted_smtp_password | base64
   -d | gpg --decrypt`.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name                                                    | Version  |
| ------------------------------------------------------- | -------- |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >=5.51.0 |

## Providers

| Name                                              | Version  |
| ------------------------------------------------- | -------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >=5.51.0 |

## Modules

No modules.

## Resources

| Name                                                                                                                               | Type        |
| ---------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_iam_access_key.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_access_key)              | resource    |
| [aws_iam_user.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user)                          | resource    |
| [aws_iam_user_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy)            | resource    |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name                                                                                                  | Description                                                                                                                               | Type           | Default | Required |
| ----------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------- | -------------- | ------- | :------: |
| <a name="input_allowed_resource_arns"></a> [allowed\_resource\_arns](#input\_allowed\_resource\_arns) | List of allowed resources for the user. Must include the email or domain identity and identity's default configuration set, if it is set. | `list(string)` | n/a     |   yes    |
| <a name="input_name"></a> [name](#input\_name)                                                        | User name. It will be visible in AWS console and in error messages, but not anywhere else.                                                | `string`       | n/a     |   yes    |
| <a name="input_pgp_key"></a> [pgp\_key](#input\_pgp\_key)                                             | PGP key to encrypt the password with. If unset, plaintext password will be in the outputs.                                                | `string`       | `null`  |    no    |

## Outputs

| Name                                                                                                          | Description                                                                                           |
| ------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------- |
| <a name="output_encrypted_smtp_password"></a> [encrypted\_smtp\_password](#output\_encrypted\_smtp\_password) | Encrypted password in base64, to be decrypted with `gpg --decrypt`. Null if `var.pgp_key` is not set. |
| <a name="output_smtp_password"></a> [smtp\_password](#output\_smtp\_password)                                 | Plain text SMTP password. Null if var.pgp\_key is set.                                                |
| <a name="output_smtp_username"></a> [smtp\_username](#output\_smtp\_username)                                 | SMTP username.                                                                                        |
<!-- END_TF_DOCS -->