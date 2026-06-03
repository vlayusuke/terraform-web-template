# ===============================================================================
# Amazon CloudWatch Log group for Login root monitoring (ap-northeast-1)
# ===============================================================================
resource "aws_cloudwatch_log_group" "root_login_monitoring" {
  name              = "/aws/lambda/${aws_lambda_function.root_login_monitoring.function_name}-cwlog"
  retention_in_days = local.retention_in_days

  tags = {
    Name = "/aws/lambda/${aws_lambda_function.root_login_monitoring.function_name}-cwlog"
  }
}

resource "aws_cloudwatch_log_stream" "root_login_monitoring" {
  name           = "${local.project}-${local.env}-cw-lmd-${aws_lambda_function.root_login_monitoring.function_name}-cwstream"
  log_group_name = aws_cloudwatch_log_group.root_login_monitoring.name
}

resource "aws_cloudwatch_log_subscription_filter" "root_login_monitoring_lambda" {
  name            = "${local.project}-${local.env}-cw-lmd-root-login-monitoring-to-lmd"
  log_group_name  = aws_cloudwatch_log_group.root_login_monitoring.name
  filter_pattern  = "{ $.responseElements.ConsoleLogin = \"Success\" && $.userIdentity.type = \"Root\" }"
  destination_arn = aws_lambda_function.root_login_monitoring.arn
}


# ===============================================================================
# Amazon CloudWatch Log group for Login root monitoring (us-east-1)
# ===============================================================================
resource "aws_cloudwatch_log_group" "root_login_monitoring_global" {
  provider          = aws.virginia
  name              = "/aws/lambda/${aws_lambda_function.root_login_monitoring_global.function_name}-cwlog-global"
  retention_in_days = local.retention_in_days

  tags = {
    Name = "/aws/lambda/${aws_lambda_function.root_login_monitoring_global.function_name}-cwlog-global"
  }
}

resource "aws_cloudwatch_log_stream" "root_login_monitoring_global" {
  provider       = aws.virginia
  name           = "${local.project}-${local.env}-cw-lmd-${aws_lambda_function.root_login_monitoring_global.function_name}-cwstream-global"
  log_group_name = aws_cloudwatch_log_group.root_login_monitoring_global.name
}

resource "aws_cloudwatch_log_subscription_filter" "root_login_monitoring_lambda_global" {
  provider        = aws.virginia
  name            = "${local.project}-${local.env}-cw-lmd-root-login-monitoring-to-lmd-global"
  log_group_name  = aws_cloudwatch_log_group.root_login_monitoring_global.name
  filter_pattern  = "{ $.responseElements.ConsoleLogin = \"Success\" && $.userIdentity.type = \"Root\" }"
  destination_arn = aws_lambda_function.root_login_monitoring_global.arn
}


# ===============================================================================
# Amazon CloudWatch Log group for Lambda errors
# ===============================================================================
resource "aws_cloudwatch_log_group" "lambda_error" {
  name              = "/aws/lambda/${aws_lambda_function.lambda_error.function_name}-cwlog"
  retention_in_days = local.retention_in_days

  tags = {
    Name = "/aws/lambda/${aws_lambda_function.lambda_error.function_name}-cwlog"
  }
}

resource "aws_cloudwatch_log_stream" "lambda_error" {
  name           = "${local.project}-${local.env}-cw-lmd-${aws_lambda_function.lambda_error.function_name}-cwstream"
  log_group_name = aws_cloudwatch_log_group.lambda_error.name
}

resource "aws_cloudwatch_log_subscription_filter" "lambda_error" {
  name            = "${local.project}-${local.env}-cw-lmd-error-to-lmd"
  log_group_name  = aws_cloudwatch_log_group.lambda_error.name
  filter_pattern  = ""
  destination_arn = aws_lambda_function.lambda_error.arn
}


# ===============================================================================
# Amazon CloudWatch Log group for Security Notice
# ===============================================================================
resource "aws_cloudwatch_log_group" "security_notice" {
  name              = "/aws/lambda/${aws_lambda_function.security_notice.function_name}-cwlog"
  retention_in_days = local.retention_in_days

  tags = {
    Name = "/aws/lambda/${aws_lambda_function.security_notice.function_name}-cwlog"
  }
}

resource "aws_cloudwatch_log_stream" "security_notice" {
  name           = "${local.project}-${local.env}-cw-lmd-${aws_lambda_function.security_notice.function_name}-cwstream"
  log_group_name = aws_cloudwatch_log_group.security_notice.name
}

resource "aws_cloudwatch_log_subscription_filter" "security_notice" {
  name            = "${local.project}-${local.env}-cw-lmd-security-notice-to-lmd"
  log_group_name  = aws_cloudwatch_log_group.security_notice.name
  filter_pattern  = ""
  destination_arn = aws_lambda_function.security_notice.arn
}


# ===============================================================================
# Amazon CloudWatch Log group for CloudWatch log error alert (Audit)
# ===============================================================================
resource "aws_cloudwatch_log_group" "lambda_log_error_alert_audit" {
  name              = "/aws/lambda/${aws_lambda_function.lambda_log_error_alert_audit.function_name}-cwlog"
  retention_in_days = local.retention_in_days

  tags = {
    Name = "/aws/lambda/${aws_lambda_function.lambda_log_error_alert_audit.function_name}-cwlog"
  }
}

resource "aws_cloudwatch_log_stream" "lambda_log_error_alert_audit" {
  name           = "${local.project}-${local.env}-cw-lmd-${aws_lambda_function.lambda_log_error_alert_audit.function_name}-cwstream"
  log_group_name = aws_cloudwatch_log_group.lambda_log_error_alert_audit.name
}

resource "aws_cloudwatch_log_subscription_filter" "lambda_log_error_alert_audit" {
  name            = "${local.project}-${local.env}-cw-lmd-log-error-alert-to-lmd"
  log_group_name  = aws_cloudwatch_log_group.lambda_log_error_alert_audit.name
  filter_pattern  = ""
  destination_arn = aws_lambda_function.lambda_log_error_alert_audit.arn
}


# ===============================================================================
# Amazon CloudWatch Log group for AWS CloudTrail (ap-northeast-1)
# ===============================================================================
resource "aws_cloudwatch_log_group" "cloudtrail" {
  name              = "${local.project}-${local.env}-cw-ct-cwlog"
  retention_in_days = local.retention_in_days

  tags = {
    Name = "${local.project}-${local.env}-cw-ct-cwlog"
  }
}

resource "aws_cloudwatch_log_stream" "cloudtrail" {
  name           = "${local.project}-${local.env}-cw-ct-cwstream"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name
}

resource "aws_cloudwatch_log_subscription_filter" "cloudtrail" {
  name            = "${local.project}-${local.env}-cw-ct-subscription-filter"
  log_group_name  = aws_cloudwatch_log_group.cloudtrail.name
  filter_pattern  = ""
  destination_arn = aws_lambda_function.lambda_log_error_alert_audit.arn
}


# ===============================================================================
# Amazon CloudWatch Log group for AWS CloudTrail (ap-northeast-3)
# ===============================================================================
resource "aws_cloudwatch_log_group" "cloudtrail_osaka" {
  provider          = aws.osaka
  name              = "${local.project}-${local.env}-cw-ct-cwlog-osaka"
  retention_in_days = local.retention_in_days

  tags = {
    Name = "${local.project}-${local.env}-cw-ct-cwlog-osaka"
  }
}


# ===============================================================================
# Amazon CloudWatch Log group for AWS CloudTrail (us-east-1)
# ===============================================================================
resource "aws_cloudwatch_log_group" "cloudtrail_global" {
  provider          = aws.virginia
  name              = "${local.project}-${local.env}-cw-ct-cwlog-global"
  retention_in_days = local.retention_in_days

  tags = {
    Name = "${local.project}-${local.env}-cw-ct-cwlog-global"
  }
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
  name            = "${local.project}-${local.env}-cw-sns-subscription-filter"
  log_group_name  = aws_cloudwatch_log_group.sns.name
  filter_pattern  = ""
  destination_arn = aws_lambda_function.lambda_log_error_alert_audit.arn
}


# ===============================================================================
# Amazon CloudWatch Metrics for AWS Lambda
# ===============================================================================
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "${local.project}-${local.env}-cw-lmd-errors-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  treat_missing_data  = "notBreaching"

  alarm_actions = [
    aws_sns_topic.event_notifications_audit.arn,
  ]

  ok_actions = [
    aws_sns_topic.event_notifications_audit.arn,
  ]

  tags = {
    Name = "${local.project}-${local.env}-cw-lmd-errors-alarm"
  }
}

resource "aws_cloudwatch_metric_alarm" "lambda_throttles" {
  alarm_name          = "${local.project}-${local.env}-cw-lmd-throttles-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "Throttles"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  treat_missing_data  = "notBreaching"

  alarm_actions = [
    aws_sns_topic.event_notifications_audit.arn,
  ]

  ok_actions = [
    aws_sns_topic.event_notifications_audit.arn,
  ]

  tags = {
    Name = "${local.project}-${local.env}-cw-lmd-throttles-alarm"
  }
}

resource "aws_cloudwatch_metric_alarm" "lambda_concurrent_executions" {
  alarm_name          = "${local.project}-${local.env}-cw-lmd-concurrent-executions-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "ConcurrentExecutions"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Maximum"
  threshold           = data.aws_servicequotas_service_quota.lambda_concurrent_executions.value * 0.8
  treat_missing_data  = "notBreaching"

  alarm_actions = [
    aws_sns_topic.event_notifications_audit.arn,
  ]

  ok_actions = [
    aws_sns_topic.event_notifications_audit.arn,
  ]

  tags = {
    Name = "${local.project}-${local.env}-cw-lmd-concurrent-executions-alarm"
  }
}

data "aws_servicequotas_service_quota" "lambda_concurrent_executions" {
  quota_name   = "Concurrent executions"
  service_code = "lambda"
}
