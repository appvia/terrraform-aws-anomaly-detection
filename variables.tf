
variable "create_sns_topic" {
  description = "Indicates whether to create an SNS topic for notifications"
  type        = bool
  default     = true
}

variable "monitors" {
  description = "A collection of cost anomaly monitors to create"
  type = list(object({
    name = string
    # The name of the monitor 
    monitor_type = optional(string, "DIMENSIONAL")
    # The type of monitor to create 
    monitor_dimension = optional(string, "SERVICE")
    # The dimension to monitor
    monitor_specification = optional(string, null)
    # The specification to monitor 

    notify = optional(object({
      frequency = string
      # The frequency of notifications
      threshold_expression = optional(any, null)
      # The threshold expression to use for notifications
      }), {
      frequency = "DAILY"
    })
  }))
}

variable "notifications" {
  description = "The configuration of the notification"
  type = object({
    email = optional(object({
      addresses = list(string)
    }), null)
    slack = optional(object({
      channel = string
      # The channel name for notifications (e.g. #channel-name) 
      secret_name = optional(string, null)
      # An optional secret name in the AWS Secrets Manager, containing this information 
      lambda_name = optional(string, "cost-anomaly-notification")
      # The name of the Lambda function to use for notifications 
      webhook_url = string
      # The URL of the Slack webhook to use for notifications
    }), null)
  })
}

variable "sns_topic_name" {
  description = "The name of an existing or new SNS topic  for notifications"
  type        = string
  default     = "cost-anomaly-notifications"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
}
