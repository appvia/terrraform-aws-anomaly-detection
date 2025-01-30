
## Provision the SNS topic for the cost anomaly detection, if required
module "notifications" {
  count   = var.enable_notification_creation ? 1 : 0
  source  = "appvia/notifications/aws"
  version = "2.0.0"

  allowed_aws_services              = ["budgets.amazonaws.com", "costalerts.amazonaws.com", "lambda.amazonaws.com"]
  create_sns_topic                  = local.enable_sns_topic_creation
  email                             = local.email
  enable_slack                      = local.enable_slack
  slack                             = local.slack
  sns_topic_name                    = var.sns_topic_name
  tags                              = var.tags
  accounts_id_to_name_parameter_arn = var.accounts_id_to_name_parameter_arn
  identity_center_start_url         = var.identity_center_start_url
  identity_center_role              = var.identity_center_role
}

## Provision the cost anomaly detection for services 
resource "aws_ce_anomaly_monitor" "this" {
  for_each = { for x in var.monitors : x.name => x }

  name                  = each.value.name
  monitor_type          = each.value.monitor_type
  monitor_dimension     = each.value.monitor_dimension
  monitor_specification = try(each.value.monitor_specification, null)
  tags                  = var.tags
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
          key           = dimension.value.dimension.key
          match_options = dimension.value.dimension.match_options
          values        = dimension.value.dimension.values
        }
      }

      dynamic "cost_category" {
        for_each = [for x in each.value.notify.threshold_expression : x if lookup(x, "cost_category", null) != null]
        content {
          key           = cost_category.value.cost_category.key
          match_options = cost_category.value.cost_category.match_options
          values        = cost_category.value.cost_category.values
        }
      }

      dynamic "tags" {
        for_each = [for x in each.value.notify.threshold_expression : x if lookup(x, "tags", null) != null]
        content {
          key           = tags.value.tags.key
          match_options = tags.value.tags.match_options
          values        = tags.value.tags.values
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
}
