# --- SNS Topic and Email Subscriptions ---

resource "aws_sns_topic" "uptime_alerts" {
  name = "${var.project_name}-alerts"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.uptime_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}
