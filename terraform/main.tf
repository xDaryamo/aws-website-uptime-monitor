module "storage" {
  source       = "./modules/storage"
  project_name = var.project_name
}

module "notifications" {
  source       = "./modules/notifications"
  project_name = var.project_name
  alert_email  = var.alert_email
}

module "monitoring" {
  source              = "./modules/monitoring"
  project_name        = var.project_name
  website_url         = var.website_url
  timezone            = var.timezone
  dynamodb_table_name = module.storage.table_name
  dynamodb_table_arn  = module.storage.table_arn
  sns_topic_arn       = module.notifications.topic_arn
}
