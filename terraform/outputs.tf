output "dynamodb_table_name" {
  value = module.storage.table_name
}

output "sns_topic_arn" {
  value = module.notifications.topic_arn
}

output "lambda_function_arn" {
  value = module.monitoring.lambda_function_arn
}
