<!-- BEGIN_TF_DOCS -->
## Providers

No providers.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_notification_email_addresses"></a> [notification\_email\_addresses](#input\_notification\_email\_addresses) | The list of email addresses to notify | `list(string)` | `[]` | no |
| <a name="input_notification_secret_name"></a> [notification\_secret\_name](#input\_notification\_secret\_name) | The name of the secret that contains the notification configuration | `string` | `"cost-anomaly-notification"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to the resources | `map(string)` | <pre>{<br/>  "Environment": "Test",<br/>  "GitRepo": "https://github.com/appvia/terraform-aws-anomaly-detection",<br/>  "Owner": "Appvia"<br/>}</pre> | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->