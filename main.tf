
## Provision the SNS topic for the cost anomaly detection, if required
module "notifications" {
  source  = "appvia/notifications/aws"
  version = "0.1.4"

  allowed_aws_services = ["budgets.amazonaws.com", "lambda.amazonaws.com"]
  create_sns_topic     = var.create_sns_topic
  email                = local.email
  slack                = local.slack
  sns_topic_name       = var.sns_topic_name
  tags                 = var.tags
}

## Provision the cost anomaly detection for services 
resource "aws_ce_anomaly_monitor" "this" {
  for_each = { for x in var.monitors : x.name => x }

  name              = each.value.name
  monitor_type      = each.value.monitor_type
  monitor_dimension = each.value.monitor_dimension
  tags              = var.tags
}

## Provision the subscriptions to the anomaly detection monitors
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
    address = module.notifications.sns_topic_arn
    type    = "SNS"
  }
}
