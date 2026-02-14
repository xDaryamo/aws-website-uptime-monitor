# --- DynamoDB Table for Time-Series Logs ---

resource "aws_dynamodb_table" "uptime_logs" {
  name         = "${var.project_name}-logs"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "SiteUrl"
  range_key    = "Timestamp"

  attribute {
    name = "SiteUrl"
    type = "S"
  }

  attribute {
    name = "Timestamp"
    type = "N"
  }

  tags = {
    Name = "Uptime Logs Table"
  }
}
