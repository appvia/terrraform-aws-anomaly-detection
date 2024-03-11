<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.40.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_slack_notfications"></a> [slack\_notfications](#module\_slack\_notfications) | terraform-aws-modules/notify-slack/aws | 6.1.1 |
| <a name="module_sns"></a> [sns](#module\_sns) | terraform-aws-modules/sns/aws | v6.0.1 |

## Resources

| Name | Type |
|------|------|
| [aws_ce_anomaly_monitor.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ce_anomaly_monitor) | resource |
| [aws_ce_anomaly_subscription.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ce_anomaly_subscription) | resource |
| [aws_sns_topic_subscription.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |
| [aws_sns_topic.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/sns_topic) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_sns_topic"></a> [create\_sns\_topic](#input\_create\_sns\_topic) | Indicates whether to create an SNS topic for notifications | `bool` | `true` | no |
| <a name="input_monitors"></a> [monitors](#input\_monitors) | A collection of cost anomaly monitors to create | <pre>list(object({<br>    name                  = string<br>    monitor_type          = optional(string, "DIMENSIONAL")<br>    monitor_dimension     = optional(string, "SERVICE")<br>    monitor_specification = optional(string, null)<br><br>    notify = optional(object({<br>      frequency            = string<br>      threshold_expression = optional(any, null)<br>      }), {<br>      frequency = "DAILY"<br>    })<br>  }))</pre> | n/a | yes |
| <a name="input_notification"></a> [notification](#input\_notification) | The configuration of the notification | <pre>object({<br>    email = optional(object({<br>      addresses = list(string)<br>    }), null)<br>    slack = optional(object({<br>      channel     = string<br>      webhook_url = string<br>    }), null)<br>    teams = optional(object({<br>      webhook_url = string<br>    }), null)<br>  })</pre> | n/a | yes |
| <a name="input_sns_topic_name"></a> [sns\_topic\_name](#input\_sns\_topic\_name) | The name of an existing or new SNS topic  for notifications | `string` | `"cost-anomaly-notifications"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->