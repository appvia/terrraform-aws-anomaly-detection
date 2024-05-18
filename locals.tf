
locals {
  ## Indicates if slack notifications are enabled 
  enable_slack = var.notifications.slack != null ? true : false
  ## Indicates if email notifications are enabled 
  enable_email = var.notifications.email != null ? true : false
  ## Indicates if we should create the sns topic 
  enable_sns_topic_creation = var.sns_topic_arn != null ? false : var.enable_sns_topic_creation

  ## The SNS arn we shuld use on the monitor, this is either the one we 
  ## created or the one provided by the user 
  sns_topic_arn = var.sns_topic_arn != null ? var.sns_topic_arn : module.notifications[0].sns_topic_arn

  ## The configuration for email notifications if enabled 
  email = local.enable_email ? {
    addresses = var.notifications.email.addresses
  } : null

  ## The configuration for slack notifications if enabled 
  slack = local.enable_slack ? {
    channel     = var.notifications.slack.channel
    lambda_name = var.notifications.slack.lambda_name
    secret_name = var.notifications.slack.secret_name
    username    = var.notifications.slack.username
    webhook_url = var.notifications.slack.webhook_url
  } : null
}

