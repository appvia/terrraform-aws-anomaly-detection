#####################################################################################
# Terraform module examples are meant to show an _example_ on how to use a module
# per use-case. The code below should not be copied directly but referenced in order
# to build your own root module that invokes this module
#####################################################################################

locals {
  monitors = [
    {
      name              = "AWS Service Cost Anomaly Monitor"
      monitor_type      = "DIMENSIONAL"
      monitor_dimension = "SERVICE"
      notify = {
        frequency = "IMMEDIATE"
        threshold_expression = [
          {
            and = {
              dimension = {
                key           = "ANOMALY_TOTAL_IMPACT_ABSOLUTE"
                match_options = ["GREATER_THAN_OR_EQUAL"]
                values        = ["100"]
              }
            }
          },
          {
            and = {
              dimension = {
                key           = "ANOMALY_TOTAL_IMPACT_PERCENTAGE"
                match_options = ["GREATER_THAN_OR_EQUAL"]
                values        = ["50"]
              }
            }
          }
        ]
      }
    }
  ]
}

## Read the secret for aws secrets manager 
data "aws_secretsmanager_secret" "notification" {
  name = var.notification_secret_name
}

## Retrieve the current version of the secret
data "aws_secretsmanager_secret_version" "notification" {
  secret_id = data.aws_secretsmanager_secret.notification.id
}

module "cost_anomaly_detection" {
  source = "../../"

  monitors       = local.monitors
  sns_topic_name = "this-is-an-existing-sns-topic"
  tags           = var.tags

  notifications = {
    email = {
      addresses = var.notification_email_addresses
    }
    slack = {
      channel     = jsondecode(data.aws_secretsmanager_secret_version.notification.secret_string).channel
      webhook_url = jsondecode(data.aws_secretsmanager_secret_version.notification.secret_string).webhook_url
    }
  }

  accounts_id_to_name = {
    "1234567890" = "mgmt"
  }
}
