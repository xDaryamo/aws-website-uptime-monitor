output "table_name" {
  value = aws_dynamodb_table.uptime_logs.name
}

output "table_arn" {
  value = aws_dynamodb_table.uptime_logs.arn
}
