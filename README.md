![Github Actions](../../actions/workflows/terraform.yml/badge.svg)

# Terraform AWS Cost Anomaly Detection

## Description

The purpose of this module is convenience wrapper for provisioning one or more Cost Anomaly monitors and setting up the nofitications for them.

## Usage

Add example usage here

```hcl
module "cost_anomaly_detection" {
  source = "../../"

  monitors = local.monitors
  notifications = {
    email = {
      addresses = var.notification_email_addresses
    }
    slack = {
      channel     = jsondecode(data.aws_secretsmanager_secret_version.notification.secret_string).channel
      webhook_url = jsondecode(data.aws_secretsmanager_secret_version.notification.secret_string).webhook_url
    }
  }
  tags = var.tags
}
}
```

## Update Documentation

The `terraform-docs` utility is used to generate this README. Follow the below steps to update:

1. Make changes to the `.terraform-docs.yml` file
2. Fetch the `terraform-docs` binary (https://terraform-docs.io/user-guide/installation/)
3. Run `terraform-docs markdown table --output-file ${PWD}/README.md --output-mode inject .`

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_notifications"></a> [notifications](#module\_notifications) | appvia/notifications/aws | 1.0.1 |

## Resources

| Name | Type |
|------|------|
| [aws_ce_anomaly_monitor.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ce_anomaly_monitor) | resource |
| [aws_ce_anomaly_subscription.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ce_anomaly_subscription) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_accounts_id_to_name"></a> [accounts\_id\_to\_name](#input\_accounts\_id\_to\_name) | A mapping of account id and account name - used by notification lamdba to map an account ID to a human readable name | `map(string)` | n/a | yes |
| <a name="input_monitors"></a> [monitors](#input\_monitors) | A collection of cost anomaly monitors to create | <pre>list(object({<br>    name = string<br>    # The name of the monitor <br>    monitor_type = optional(string, "DIMENSIONAL")<br>    # The type of monitor to create <br>    monitor_dimension = optional(string, "DIMENSIONAL")<br>    # The dimension to monitor<br>    monitor_specification = optional(string, null)<br>    # The specification to monitor <br>    notify = optional(object({<br>      frequency = string<br>      # The frequency of notifications<br>      threshold_expression = optional(any, null)<br>      # The threshold expression to use for notifications<br>      }), {<br>      frequency = "DAILY"<br>    })<br>  }))</pre> | n/a | yes |
| <a name="input_notifications"></a> [notifications](#input\_notifications) | The configuration of the notification | <pre>object({<br>    email = optional(object({<br>      addresses = list(string)<br>    }), null)<br>    slack = optional(object({<br>      secret_name = optional(string, null)<br>      # An optional secret name in the AWS Secrets Manager, containing this information <br>      lambda_name = optional(string, "cost-anomaly-notification")<br>      # The name of the Lambda function to use for notifications <br>      webhook_url = optional(string, null)<br>      # The URL of the Slack webhook to use for notifications, required if secret_name is not provided<br>    }), null)<br>  })</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | n/a | yes |
| <a name="input_enable_notification_creation"></a> [enable\_notification\_creation](#input\_enable\_notification\_creation) | Indicates whether to create a notification lambda stack, default is true, but useful to toggle if using existing resources | `bool` | `true` | no |
| <a name="input_enable_sns_topic_creation"></a> [enable\_sns\_topic\_creation](#input\_enable\_sns\_topic\_creation) | Indicates whether to create an SNS topic within this module | `bool` | `true` | no |
| <a name="input_sns_topic_arn"></a> [sns\_topic\_arn](#input\_sns\_topic\_arn) | The ARN of an existing SNS topic for notifications | `string` | `null` | no |
| <a name="input_sns_topic_name"></a> [sns\_topic\_name](#input\_sns\_topic\_name) | The name of an existing or new SNS topic  for notifications | `string` | `"cost-anomaly-notifications"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
