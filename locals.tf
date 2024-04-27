
locals {
  ## Indicates if slack notifications are enabled 
  enable_slack = var.notifications.slack != null ? true : false
  ## Indicates if email notifications are enabled 
  enable_email = var.notifications.email != null ? true : false

  ## The configuration for email notifications if enabled 
  email = local.enable_email ? {
    addresses = var.notifications.email.addresses
  } : null

  ## The configuration for slack notifications if enabled 
  slack = local.enable_slack ? {
    channel     = var.notifications.slack.channel
    secret_name = var.notifications.slack.secret_name
    username    = var.notifications.slack.username
    webhook_url = var.notifications.slack.webhook_url
  } : null
}

