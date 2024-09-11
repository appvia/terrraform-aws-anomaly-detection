<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0 |
| <a name="requirement_awscc"></a> [awscc](#requirement\_awscc) | >= 0.11.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.66.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cost_anomaly_detection"></a> [cost\_anomaly\_detection](#module\_cost\_anomaly\_detection) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_secretsmanager_secret.notification](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) | data source |
| [aws_secretsmanager_secret_version.notification](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_notification_email_addresses"></a> [notification\_email\_addresses](#input\_notification\_email\_addresses) | The list of email addresses to notify | `list(string)` | `[]` | no |
| <a name="input_notification_secret_name"></a> [notification\_secret\_name](#input\_notification\_secret\_name) | The name of the secret that contains the notification configuration | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to the resources | `map(string)` | `{}` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->