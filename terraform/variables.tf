variable "aws_region" {
  description = "AWS region where resources will be deployed"
  type        = string
  default     = "eu-south-1"
}

variable "project_name" {
  description = "Project name used as a prefix for resource naming"
  type        = string
  default     = "website-uptime-monitor"
}

variable "alert_email" {
  description = "Email address to receive downtime alerts"
  type        = string
}

variable "website_url" {
  description = "The URL of the website to monitor"
  type        = string
}

variable "timezone" {
  description = "The timezone for the maintenance window (e.g., Europe/Rome)"
  type        = string
  default     = "UTC"
}
