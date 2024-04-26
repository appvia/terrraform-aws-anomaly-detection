
locals {
  ## Indicates if slack notifications are enabled 
  enable_slack = var.notifications.slack != null ? true : false

  ## The configuration for slack notifications if enabled 
  slack = local.enable_slack ? {
    channel     = var.notifications.slack.channel
    secret_name = var.notifications.slack.secret_name
    username    = var.notifications.slack.username
    webhook_url = var.notifications.slack.webhook_url
  } : null
}

