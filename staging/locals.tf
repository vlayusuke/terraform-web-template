# ================================================================================
# Local Values in staging
# ================================================================================

# ================================================================================
# Environment
# ================================================================================
locals {
  env             = "stg"
  repository_name = "vlayusuke"
}


# ================================================================================
# AWS IAM
# ================================================================================
locals {
  iam_infra_group = "${local.project}-${local.env}-iam-infra-group"
}


# ================================================================================
# Network
# ================================================================================
locals {
  vpc_cidr_block       = "10.30.0.0/16"
  default_gateway_cidr = "0.0.0.0/0"
}


# ================================================================================
# Amazon Aurora
# ================================================================================
locals {
  aurora_mysql_version = "8.0.mysql_aurora.3.12.0"
  rds_max_connections  = 512
}


# ================================================================================
# Amazon ElastiCache
# ================================================================================
locals {
  elasticache_redis_version = "7.2"
}


# ================================================================================
# Amazon CloudWatch Logs
# ================================================================================
locals {
  retention_in_days = 180

  lambda_functions = toset([
    aws_lambda_function.lambda_rds_control.function_name,
    aws_lambda_function.lambda_log_error_alert.function_name,
    aws_lambda_function.lambda_metric_alarm.function_name,
    aws_lambda_function.lambda_schedule_ecs_maintenance.function_name,
    aws_lambda_function.lambda_execute_ecs_force_deployment.function_name,
  ])

  fargate_app_cloudwatch_log_group = toset([
    "app-app",
    "cron",
    "queue",
    "migrate",
  ])

  fargate_nginx_cloudwatch_log_group = toset([
    "app-nginx"
  ])

  aurora_cloudwatch_log_group = toset([
    "audit",
    "error",
    "general",
    "slowquery",
    "iam-db-auth-error"
  ])

  aurora_adf_stream_arns = {
    "audit"             = aws_kinesis_firehose_delivery_stream.aurora_logs_audit.arn,
    "error"             = aws_kinesis_firehose_delivery_stream.aurora_logs_error.arn,
    "general"           = aws_kinesis_firehose_delivery_stream.aurora_logs_general.arn,
    "slowquery"         = aws_kinesis_firehose_delivery_stream.aurora_logs_slowquery.arn,
    "iam-db-auth-error" = aws_kinesis_firehose_delivery_stream.aurora_logs_iam_db_auth_error.arn,
  }
}


# ================================================================================
# AWS Lambda
# ================================================================================
locals {
  ssm_parameter_store_timeout_millis = 3000
  ecs_maintenance_time               = 2
}


# ================================================================================
# Amazon S3
# ================================================================================
locals {
  transition_days = 365
  expire_days     = 1827
}


# ================================================================================
# AWS WAFv2 Rule Notification ARN
# ================================================================================
locals {
  wafv2_rule_notification_arn = "arn:aws:sns:us-east-1:248400274283:aws-managed-waf-rule-notifications"
}
