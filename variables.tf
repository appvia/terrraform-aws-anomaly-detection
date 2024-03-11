
variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
}

variable "monitors" {
  description = "A collection of cost anomaly monitors to create"
  type = list(object({
    name                  = string
    monitor_type          = optional(string, "DIMENSIONAL")
    monitor_dimension     = optional(string, "SERVICE")
    monitor_specification = optional(string, null)

    notify = optional(object({
      frequency            = string
      threshold_expression = optional(any, null)
      }), {
      frequency = "DAILY"
    })
  }))
}

variable "notification" {
  description = "The configuration of the notification"
  type = object({
    email = optional(object({
      addresses = list(string)
    }), null)
    slack = optional(object({
      channel     = string
      webhook_url = string
    }), null)
    teams = optional(object({
      webhook_url = string
    }), null)
  })
}

variable "create_sns_topic" {
  description = "Indicates whether to create an SNS topic for notifications"
  type        = bool
  default     = true
}

variable "sns_topic_name" {
  description = "The name of an existing or new SNS topic  for notifications"
  type        = string
  default     = "cost-anomaly-notifications"
}
