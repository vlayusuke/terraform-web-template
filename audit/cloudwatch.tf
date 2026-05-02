# ===============================================================================
# Amazon CloudWatch Log group for AWS Lambda Function
# ===============================================================================
resource "aws_cloudwatch_log_group" "lamba_function" {
  for_each          = local.lambda_functions
  name              = "/aws/lambda/${each.key}-cwlog"
  retention_in_days = local.retention_in_days

  tags = {
    Name = "/aws/lambda/${each.key}-cwlog"
  }
}

resource "aws_cloudwatch_log_stream" "lambda_function" {
  for_each       = local.lambda_functions
  name           = "${local.project}-${local.env}-cw-lmd-${each.key}-cwstream"
  log_group_name = aws_cloudwatch_log_group.lambda_functions[each.key].name
}

resource "aws_cloudwatch_log_subscription_filter" "root_login_monitoring" {
  name            = aws_lambda_function.root_login_monitoring.function_name
  log_group_name  = aws_cloudwatch_log_group.lambda_function[aws_lambda_function.root_login_monitoring.function_name].name
  filter_pattern  = "{ $.responseElements.ConsoleLogin = \"Success\" && $.userIdentity.type = \"Root\" }"
  destination_arn = aws_lambda_function.root_login_monitoring.arn
}

resource "aws_cloudwatch_log_subscription_filter" "lambda_error" {
  name            = aws_lambda_function.lambda_error.function_name
  log_group_name  = aws_cloudwatch_log_group.lambda_function[aws_lambda_function.lambda_error.function_name].name
  filter_pattern  = ""
  destination_arn = aws_lambda_function.lambda_error.arn
}

resource "aws_cloudwatch_log_subscription_filter" "security_notice" {
  name            = aws_lambda_function.security_notice.function_name
  log_group_name  = aws_cloudwatch_log_group.lambda_function[aws_lambda_function.security_notice.function_name].name
  filter_pattern  = ""
  destination_arn = aws_lambda_function.security_notice.arn
}


# ===============================================================================
# Amazon CloudWatch Log group for AWS CloudTrail
# ===============================================================================
resource "aws_cloudwatch_log_group" "cloudtrail" {
  name              = "${local.project}-${local.env}-cw-cloudtrail-cwlog"
  retention_in_days = local.retention_in_days

  tags = {
    Name = "${local.project}-${local.env}-cw-cloudtrail-cwlog"
  }
}

resource "aws_cloudwatch_log_stream" "cloudtrail" {
  name           = "${local.project}-${local.env}-cw-cloudtrail-cwstream"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name
}

resource "aws_cloudwatch_log_subscription_filter" "cloudtrail" {
  name            = "${local.project}-${local.env}-cw-cloudtrail"
  log_group_name  = aws_cloudwatch_log_group.cloudtrail.name
  filter_pattern  = ""
  destination_arn = aws_lambda_function.lambda_log_error_alert_audit.arn
}


# ===============================================================================
# Amazon CloudWatch Log group for Amazon SNS
# ===============================================================================
resource "aws_cloudwatch_log_group" "sns" {
  name              = "${local.project}-${local.env}-cw-sns-cwlog"
  retention_in_days = local.retention_in_days

  tags = {
    Name = "${local.project}-${local.env}-cw-sns-cwlog"
  }
}

resource "aws_cloudwatch_log_stream" "sns" {
  name           = "${local.project}-${local.env}-cw-sns-cwstream"
  log_group_name = aws_cloudwatch_log_group.sns.name
}

resource "aws_cloudwatch_log_subscription_filter" "sns" {
  name            = "${local.project}-${local.env}-cw-sns"
  log_group_name  = aws_cloudwatch_log_group.sns.name
  filter_pattern  = ""
  destination_arn = aws_lambda_function.lambda_log_error_alert_audit.arn
}


# ===============================================================================
# Amazon CloudWatch Metrics for AWS Lambda
# ===============================================================================
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "${local.project}-${local.env}-cw-lambda-errors-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  treat_missing_data  = "notBreaching"

  alarm_actions = [
    aws_sns_topic.to_slack_audit.arn,
  ]

  ok_actions = [
    aws_sns_topic.to_slack_audit.arn,
  ]

  tags = {
    Name = "${local.project}-${local.env}-cw-lambda-errors-alarm"
  }
}

resource "aws_cloudwatch_metric_alarm" "lambda_throttles" {
  alarm_name          = "${local.project}-${local.env}-cw-lambda-throttles-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "Throttles"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  treat_missing_data  = "notBreaching"

  alarm_actions = [
    aws_sns_topic.to_slack_audit.arn,
  ]

  ok_actions = [
    aws_sns_topic.to_slack_audit.arn,
  ]

  tags = {
    Name = "${local.project}-${local.env}-cw-lambda-throttles-alarm"
  }
}

resource "aws_cloudwatch_metric_alarm" "lambda_concurrent_executions" {
  alarm_name          = "${local.project}-${local.env}-cw-lambda-concurrent-executions-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "ConcurrentExecutions"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Maximum"
  threshold           = data.aws_servicequotas_service_quota.lambda_concurrent_executions.value * 0.8
  treat_missing_data  = "notBreaching"

  alarm_actions = [
    aws_sns_topic.to_slack_audit.arn,
  ]

  ok_actions = [
    aws_sns_topic.to_slack_audit.arn,
  ]

  tags = {
    Name = "${local.project}-${local.env}-cw-lambda-concurrent-executions-alarm"
  }
}

data "aws_servicequotas_service_quota" "lambda_concurrent_executions" {
  quota_name   = "Concurrent executions"
  service_code = "lambda"
}
