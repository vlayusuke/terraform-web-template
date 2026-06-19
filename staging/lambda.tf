# ===============================================================================
# AWS Lambda Function for Amazon CloudWatch Logs Error Alert
# ===============================================================================
resource "aws_lambda_function" "lambda_log_error_alert" {
  function_name    = "lmd-cwt-log-error-alert"
  role             = aws_iam_role.lambda_cloudwatch.arn
  handler          = "lambda_function.lambda_handler"
  filename         = data.archive_file.log_error_alert.output_path
  source_code_hash = data.archive_file.log_error_alert.output_base64sha256
  runtime          = "python3.14"
  timeout          = 10
  memory_size      = 128

  architectures = [
    "arm64",
  ]

  environment {
    variables = {
      hook_url = var.hook_url_app
    }
  }

  lifecycle {
    ignore_changes = [
      source_code_hash,
    ]
  }

  tags = {
    Name = "${local.project}-${local.env}-lmd-cwt-log-error-alert"
  }
}

data "archive_file" "log_error_alert" {
  type        = "zip"
  source_dir  = "${path.cwd}/files/lambda/log-error-alert"
  output_path = "${path.module}/artifacts/log-error-alert.zip"
}

resource "aws_lambda_permission" "lambda_cloudwatch_app" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_log_error_alert.function_name
  principal     = "logs.${local.region}.amazonaws.com"
  source_arn    = "arn:aws:logs:${local.region}:${data.aws_caller_identity.current.account_id}:log-group:*"
}


# ===============================================================================
# AWS Lambda Function for Amazon CloudWatch Metric Alarm
# ===============================================================================
resource "aws_lambda_function" "lambda_metric_alarm" {
  function_name    = "lmd-cwt-metric-alarm"
  role             = aws_iam_role.lambda_cloudwatch.arn
  handler          = "lambda_function.lambda_handler"
  filename         = data.archive_file.metric_alarm.output_path
  source_code_hash = data.archive_file.metric_alarm.output_base64sha256
  runtime          = "python3.14"
  timeout          = 10
  memory_size      = 128

  architectures = [
    "arm64",
  ]

  environment {
    variables = {
      hook_url = var.hook_url_app
      region   = local.region
    }
  }

  lifecycle {
    ignore_changes = [
      source_code_hash,
    ]
  }

  tags = {
    Name = "${local.project}-${local.env}-lmd-cwt-metric-alarm"
  }
}

data "archive_file" "metric_alarm" {
  type        = "zip"
  source_dir  = "${path.cwd}/files/lambda/metric-alarm"
  output_path = "${path.module}/artifacts/metric-alarm.zip"
}

resource "aws_lambda_permission" "lambda_metric_alarm" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_metric_alarm.function_name
  principal     = "cloudwatch.amazonaws.com"
  source_arn    = "arn:aws:cloudwatch:${local.region}:${data.aws_caller_identity.current.account_id}:alarm:*"
}


# ===============================================================================
# AWS Lambda Function for RDS Control
# ===============================================================================
resource "aws_lambda_function" "rds_control" {
  function_name    = "lmd-rds-control"
  role             = aws_iam_role.rds_control.arn
  handler          = "lambda_function.lambda_handler"
  filename         = data.archive_file.rds_control.output_path
  source_code_hash = data.archive_file.rds_control.output_base64sha256
  runtime          = "python3.14"
  timeout          = 10
  memory_size      = 128

  architectures = [
    "arm64",
  ]

  lifecycle {
    ignore_changes = [
      source_code_hash,
    ]
  }

  tags = {
    Name = "${local.project}-${local.env}-lmd-rds-control"
  }
}

data "archive_file" "rds_control" {
  type        = "zip"
  source_dir  = "${path.cwd}/files/lambda/rds-control"
  output_path = "${path.module}/artifacts/rds-control.zip"
}

resource "aws_lambda_function_event_invoke_config" "rds_control" {
  function_name = aws_lambda_function.rds_control.function_name

  destination_config {
    on_failure {
      destination = aws_sns_topic.event_alarm.arn
    }

    on_success {
      destination = aws_sns_topic.event_alarm.arn
    }
  }
}

resource "aws_lambda_permission" "rds_control" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rds_control.function_name
  principal     = "logs.${local.region}.amazonaws.com"
  source_arn    = "arn:aws:logs:${local.region}:${data.aws_caller_identity.current.account_id}:log-group:*"
}


# ===============================================================================
# AWS Lambda Function for Create EventBridge Scheduler
# ===============================================================================
resource "aws_lambda_function" "lambda_schedule_ecs_maintenance" {
  function_name    = "lmd-schedule-ecs-maintenance"
  role             = aws_iam_role.lambda_schedule_ecs_maintenance.arn
  handler          = "lambda_function.lambda_handler"
  filename         = data.archive_file.lambda_schedule_ecs_maintenance.output_path
  source_code_hash = data.archive_file.lambda_schedule_ecs_maintenance.output_base64sha256
  runtime          = "python3.14"
  timeout          = 10
  memory_size      = 128

  architectures = [
    "arm64",
  ]

  environment {
    variables = {
      EXECUTE_LAMBDA_ARN   = aws_lambda_function.lambda_execute_ecs_force_deployment.arn
      SCHEDULER_ROLE_ARN   = aws_iam_role.eventbridge_scheduler_maintenance_ecs.arn
      ECS_MAINTENANCE_TIME = local.ecs_maintenance_time
    }
  }

  lifecycle {
    ignore_changes = [
      source_code_hash,
    ]
  }

  tags = {
    Name = "${local.project}-${local.env}-lmd-schedule-ecs-maintenance"
  }
}

resource "aws_lambda_function_event_invoke_config" "lambda_schedule_ecs_maintenance" {
  function_name = aws_lambda_function.lambda_schedule_ecs_maintenance.function_name

  destination_config {
    on_failure {
      destination = aws_sns_topic.event_alarm.arn
    }

    on_success {
      destination = aws_sns_topic.event_alarm.arn
    }
  }
}

data "archive_file" "lambda_schedule_ecs_maintenance" {
  type        = "zip"
  source_dir  = "${path.cwd}/files/lambda/schedule-ecs-maintenance"
  output_path = "${path.module}/artifacts/schedule-ecs-maintenance.zip"
}

resource "aws_lambda_permission" "lambda_schedule_ecs_maintenance" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_schedule_ecs_maintenance.function_name
  principal     = "logs.${local.region}.amazonaws.com"
  source_arn    = "arn:aws:logs:${local.region}:${data.aws_caller_identity.current.account_id}:log-group:*"
}

resource "aws_lambda_permission" "allow_eventbridge_to_call_lambda" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_schedule_ecs_maintenance.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.detect_ecs_task_retirement.arn
}


# ===============================================================================
# AWS Lambda Function for Execute ECS Force Deployment
# ===============================================================================
resource "aws_lambda_function" "lambda_execute_ecs_force_deployment" {
  function_name    = "lmd-execute-ecs-force-deployment"
  role             = aws_iam_role.lambda_execute_ecs_force_deployment.arn
  handler          = "lambda_function.lambda_handler"
  filename         = data.archive_file.lambda_execute_ecs_force_deployment.output_path
  source_code_hash = data.archive_file.lambda_execute_ecs_force_deployment.output_base64sha256
  runtime          = "python3.14"
  timeout          = 10
  memory_size      = 128

  architectures = [
    "arm64",
  ]

  lifecycle {
    ignore_changes = [
      source_code_hash,
    ]
  }

  tags = {
    Name = "${local.project}-${local.env}-lmd-execute-ecs-force-deployment"
  }
}

data "archive_file" "lambda_execute_ecs_force_deployment" {
  type        = "zip"
  source_dir  = "${path.cwd}/files/lambda/execute-ecs-force-deployment"
  output_path = "${path.module}/artifacts/execute-ecs-force-deployment.zip"
}

resource "aws_lambda_function_event_invoke_config" "lambda_execute_ecs_force_deployment" {
  function_name = aws_lambda_function.lambda_execute_ecs_force_deployment.function_name

  destination_config {
    on_failure {
      destination = aws_sns_topic.event_alarm.arn
    }

    on_success {
      destination = aws_sns_topic.event_alarm.arn
    }
  }
}

resource "aws_lambda_permission" "lambda_execute_ecs_force_deployment" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_execute_ecs_force_deployment.function_name
  principal     = "logs.${local.region}.amazonaws.com"
  source_arn    = "arn:aws:logs:${local.region}:${data.aws_caller_identity.current.account_id}:log-group:*"
}
