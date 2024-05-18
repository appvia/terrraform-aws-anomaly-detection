
variable "notification_secret_name" {
  description = "The name of the secret that contains the notification configuration"
  type        = string
  default     = "cost-anomaly-notification"
}

variable "notification_email_addresses" {
  description = "The list of email addresses to notify"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A map of tags to add to the resources"
  type        = map(string)
  default = {
    Environment = "Test"
    Owner       = "Appvia"
    GitRepo     = "https://github.com/appvia/terraform-aws-anomaly-detection"
  }
}
