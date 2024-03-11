#
## Related to the provisioning of services 
#

locals {
  # The SNS topic ARN to use for the cost anomaly detection
  sns_topic_arn = var.create_sns_topic ? module.sns[0].topic_arn : data.aws_sns_topic.current[0].arn
}

#
## We need to lookup the SNS topic ARN, if it exists
#
data "aws_sns_topic" "current" {
  count = var.create_sns_topic ? 0 : 1
  name  = var.sns_topic_name
}

# 
## Provision the SNS topic for the cost anomaly detection, if required
#
module "sns" {
  source  = "terraform-aws-modules/sns/aws"
  version = "v6.0.1"
  count   = var.create_sns_topic ? 1 : 0

  name = var.sns_topic_name
  tags = var.tags
  topic_policy_statements = {
    "AllowBudgetsToNotifySNSTopic" = {
      actions = ["sns:Publish"]
      effect  = "Allow"
      principals = [{
        type        = "Service"
        identifiers = ["budgets.amazonaws.com"]
      }]
    }
    "AllowLambda" = {
      actions = [
        "sns:Subscribe",
      ]
      effect = "Allow"
      principals = [{
        type        = "Service"
        identifiers = ["lambda.amazonaws.com"]
      }]
    }
  }
}

#
## Provision the cost anomaly detection for services 
#
resource "aws_ce_anomaly_monitor" "this" {
  for_each = { for x in var.monitors : x.name => x }

  name              = each.value.name
  monitor_type      = each.value.monitor_type
  monitor_dimension = each.value.monitor_dimension
  #monitor_specification = each.value.monitor_specification != "" ? jsonencode(each.value.monitor_specification) : ""
  tags = var.tags
}

#
## Provision the subscriptions to the anomaly detection monitors
#
resource "aws_ce_anomaly_subscription" "this" {
  for_each = { for x in var.monitors : x.name => x }

  name             = each.value.name
  frequency        = each.value.notify.frequency
  monitor_arn_list = [aws_ce_anomaly_monitor.this[each.key].arn]
  tags             = var.tags

  dynamic "threshold_expression" {
    for_each = [each.value.notify.threshold_expression != null ? [1] : []]
    content {
      dynamic "dimension" {
        for_each = [for x in each.value.notify.threshold_expression : x if lookup(x, "dimension", null) != null]
        content {
          key           = dimension.value.key
          match_options = dimension.value.match_options
          values        = dimension.value.values
        }
      }

      dynamic "cost_category" {
        for_each = [for x in each.value.notify.threshold_expression : x if lookup(x, "cost_category", null) != null]
        content {
          key           = cost_category.value.key
          match_options = cost_category.value.match_options
          values        = cost_category.value.values
        }
      }

      dynamic "tags" {
        for_each = [for x in each.value.notify.threshold_expression : x if lookup(x, "tags", null) != null]
        content {
          key           = tags.value.key
          match_options = tags.value.match_options
          values        = tags.value.values
        }
      }

      dynamic "and" {
        for_each = [for x in each.value.notify.threshold_expression : x if lookup(x, "and", null) != null]
        content {
          dynamic "dimension" {
            for_each = and.value.and.dimension != null ? [and.value.and.dimension] : []
            content {
              key           = dimension.value.key
              match_options = dimension.value.match_options
              values        = dimension.value.values
            }
          }
        }
      }

      dynamic "or" {
        for_each = [for x in each.value.notify.threshold_expression : x if lookup(x, "or", null) != null]
        content {
          dynamic "dimension" {
            for_each = or.value.or.dimension != null ? [or.value.or.dimension] : []
            content {
              key           = dimension.value.key
              match_options = dimension.value.match_options
              values        = dimension.value.values
            }
          }
        }
      }

      dynamic "not" {
        for_each = [for x in each.value.notify.threshold_expression : x if lookup(x, "not", null) != null]
        content {
          dynamic "dimension" {
            for_each = not.value.not.dimension != null ? [not.value.not.dimension] : []
            content {
              key           = dimension.value.key
              match_options = dimension.value.match_options
              values        = dimension.value.values
            }
          }
        }
      }
    }
  }

  subscriber {
    address = local.sns_topic_arn
    type    = "SNS"
  }

  depends_on = [module.sns]
}

#
## Provision any additional notification subscriptions (email) 
#
resource "aws_sns_topic_subscription" "main" {
  for_each = { for x in var.notification.email.addresses : x => x }

  endpoint  = each.value
  protocol  = "email"
  topic_arn = local.sns_topic_arn
}


#
## Provision a slack notification if required
#
# tfsec:ignore:aws-lambda-enable-tracing
# tfsec:ignore:aws-lambda-restrict-source-arn
module "slack_notfications" {
  count   = var.notification.slack != null ? 1 : 0
  source  = "terraform-aws-modules/notify-slack/aws"
  version = "6.1.1"

  create_sns_topic     = false
  lambda_function_name = "cost-anomaly-detection"
  slack_channel        = var.notification.slack.channel
  slack_username       = ":aws: (Cost Anomaly Detection)"
  slack_webhook_url    = var.notification.slack.webhook_url
  sns_topic_name       = var.sns_topic_name
  tags                 = var.tags
}

