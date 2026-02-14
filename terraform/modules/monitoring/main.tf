# --- Lambda Function and Packaging ---

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../../../src/monitor.py"
  output_path = "${path.module}/../../../src/monitor.zip"
}

resource "aws_lambda_function" "uptime_monitor" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "${var.project_name}-function"
  role             = aws_iam_role.lambda_role.arn
  handler          = "monitor.lambda_handler"
  runtime          = "python3.11"
  timeout          = 30

  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      DYNAMODB_TABLE = var.dynamodb_table_name
      SNS_TOPIC_ARN  = var.sns_topic_arn
      WEBSITE_URL    = var.website_url
      TIMEZONE       = var.timezone
    }
  }
}

# --- IAM Role and Policies ---

resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "lambda_custom_policy" {
  name        = "${var.project_name}-custom-policy"
  description = "Allows Lambda to write to DynamoDB and publish to SNS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:PutItem",
          "dynamodb:UpdateItem"
        ]
        Effect   = "Allow"
        Resource = var.dynamodb_table_arn
      },
      {
        Action = [
          "sns:Publish"
        ]
        Effect   = "Allow"
        Resource = var.sns_topic_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_custom_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_custom_policy.arn
}

# --- CloudWatch Events (Scheduler) ---

resource "aws_cloudwatch_event_rule" "every_five_minutes" {
  name                = "${var.project_name}-schedule"
  description         = "Triggers the uptime monitor Lambda every 5 minutes"
  schedule_expression = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_target" "trigger_lambda_on_schedule" {
  rule      = aws_cloudwatch_event_rule.every_five_minutes.name
  target_id = "uptime_monitor_lambda"
  arn       = aws_lambda_function.uptime_monitor.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_monitor" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.uptime_monitor.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_five_minutes.arn
}
