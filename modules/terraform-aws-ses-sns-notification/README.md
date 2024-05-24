# Amazon SES Configuration Set for SNS Notifications

Creates an SES configuration set, an SNS topic, subscribes the topic to the configuration set's
notifications, and subscribes a given address to the topic.

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

| Name                                                                                                                                                                        | Type     |
| --------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| [aws_sesv2_configuration_set.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sesv2_configuration_set)                                     | resource |
| [aws_sesv2_configuration_set_event_destination.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sesv2_configuration_set_event_destination) | resource |
| [aws_sns_topic.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic)                                                                 | resource |
| [aws_sns_topic_subscription.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription)                                       | resource |

## Inputs

| Name                                                                                             | Description                                                       | Type           | Default                                                                                                      | Required |
| ------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------- | -------------- | ------------------------------------------------------------------------------------------------------------ | :------: |
| <a name="input_event_types"></a> [event\_types](#input\_event\_types)                            | Types of events to subscribe for. Defaults to problematic events. | `list(string)` | <pre>[<br>  "BOUNCE",<br>  "COMPLAINT",<br>  "DELIVERY_DELAY",<br>  "REJECT",<br>  "SUBSCRIPTION"<br>]</pre> |    no    |
| <a name="input_name"></a> [name](#input\_name)                                                   | Configuration set name. The topic name will be derived from it.   | `string`       | n/a                                                                                                          |   yes    |
| <a name="input_notification_address"></a> [notification\_address](#input\_notification\_address) | Email address to send notifications to.                           | `string`       | n/a                                                                                                          |   yes    |

## Outputs

| Name                                                                                                       | Description             |
| ---------------------------------------------------------------------------------------------------------- | ----------------------- |
| <a name="output_configuration_set_arn"></a> [configuration\_set\_arn](#output\_configuration\_set\_arn)    | Configuration set ARN.  |
| <a name="output_configuration_set_name"></a> [configuration\_set\_name](#output\_configuration\_set\_name) | Configuration set name. |
<!-- END_TF_DOCS -->