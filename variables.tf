
variable "enable_sns_topic_creation" {
  description = "Indicates whether to create an SNS topic within this module"
  type        = bool
  default     = true
}

variable "enable_notification_creation" {
  description = "Indicates whether to create a notification lambda stack, default is true, but useful to toggle if using existing resources"
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
    monitor_dimension = optional(string, "DIMENSIONAL")
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
      secret_name = optional(string, null)
      # An optional secret name in the AWS Secrets Manager, containing this information 
      lambda_name = optional(string, "cost-anomaly-notification")
      # The name of the Lambda function to use for notifications 
      webhook_url = optional(string, null)
      # The URL of the Slack webhook to use for notifications, required if secret_name is not provided
    }), null)
  })
}

variable "sns_topic_name" {
  description = "The name of an existing or new SNS topic  for notifications"
  type        = string
  default     = "cost-anomaly-notifications"
}

variable "sns_topic_arn" {
  description = "The ARN of an existing SNS topic for notifications"
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
}

variable "accounts_id_to_name_parameter_arn" {
  description = "The ARN of your parameter containing the your account ID to name mapping. This ARN will be attached to lambda execution role as a resource, therefore a valid resource must exist. e.g 'arn:aws:ssm:eu-west-2:0123456778:parameter/myorg/configmaps/accounts_id_to_name_mapping' to enable the lambda retrieve values from ssm."
  type        = string
  default     = null
}

variable "identity_center_start_url" {
  description = "The start URL of your Identity Center instance"
  type        = string
  default     = null
}

variable "identity_center_role" {
  description = "The name of the role to use when redirecting through Identity Center"
  type        = string
  default     = null
}
