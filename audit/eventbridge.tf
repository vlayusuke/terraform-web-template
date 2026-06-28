# ===============================================================================
# Amazon EventBridge (AWS Config compliance check)
# ===============================================================================
resource "aws_cloudwatch_event_rule" "config_check_compliance" {
  name           = "${local.project}-${local.env}-ebd-cfg-check-compliance"
  description    = "EventBridge rule to capture AWS Config compliance check events"
  event_bus_name = "default"

  event_pattern = jsonencode({
    "source" : [
      "aws.config"
    ],
    "detail-type" : [
      "Config Rules Complete Change"
    ],
    "detail" : {
      "messageType" : [
        "ComplianceChangeNotification"
      ]
    }
  })

  tags = {
    Name = "${local.project}-${local.env}-ebd-cfg-check-compliance"
  }
}

resource "aws_cloudwatch_event_target" "config_check_compliance" {
  rule      = aws_cloudwatch_event_rule.config_check_compliance.name
  target_id = aws_sns_topic.event_notifications_audit.name
  arn       = aws_sns_topic.event_notifications_audit.arn
}


# ===============================================================================
# Amazon EventBridge (AWS Config capture non-compliance)
# ===============================================================================
resource "aws_cloudwatch_event_rule" "config_non_compliance" {
  name           = "${local.project}-${local.env}-ebd-cfg-non-compliance"
  description    = "EventBridge rule to capture AWS Config non-compliance events"
  event_bus_name = "default"

  event_pattern = jsonencode({
    "source" : [
      "aws.config"
    ],
    "detail-type" : [
      "Config Rules Compliance Change"
    ],
    "detail" : {
      "complianceType" : [
        "NON_COMPLIANT"
      ]
    }
  })

  tags = {
    Name = "${local.project}-${local.env}-ebd-cfg-non-compliance"
  }
}

resource "aws_cloudwatch_event_target" "config_non_compliance" {
  rule      = aws_cloudwatch_event_rule.config_non_compliance.name
  target_id = aws_sns_topic.config_notifications.name
  arn       = aws_sns_topic.config_notifications.arn
}


# ==============================================================================
# Amazon EventBridge (AWS Config configuration item changes)
# ==============================================================================
resource "aws_cloudwatch_event_rule" "config_item_change" {
  name           = "${local.project}-${local.env}-ebd-cfg-item-change"
  description    = "EventBridge rule to capture AWS Config configuration item changes"
  event_bus_name = "default"

  event_pattern = jsonencode({
    "source" : [
      "aws.config"
    ],
    "detail-type" : [
      "ConfigurationItemChangeNotification",
      "OversizedConfigurationItemChangeNotification"
    ]
  })

  tags = {
    Name = "${local.project}-${local.env}-ebd-cfg-item-change"
  }
}

resource "aws_cloudwatch_event_target" "config_item_change" {
  rule      = aws_cloudwatch_event_rule.config_item_change.name
  target_id = aws_sns_topic.config_notifications.name
  arn       = aws_sns_topic.config_notifications.arn
}


# ===============================================================================
# Amazon EventBridge (AWS CloudTrail check for API calls)
# ===============================================================================
resource "aws_cloudwatch_event_rule" "cloudtrail_check_api_calls" {
  name           = "${local.project}-${local.env}-ebd-ctl-check-api-calls"
  description    = "EventBridge rule to capture AWS CloudTrail API call events"
  event_bus_name = "default"

  event_pattern = jsonencode({
    "source" : [
      "aws.cloudtrail"
    ],
    "detail-type" : [
      "AWS API Call via CloudTrail"
    ],
    "detail" : {
      "eventSource" : [
        "signin.amazonaws.com",
        "monitoring.amazonaws.com",
        "iam.amazonaws.com",
        "elasticloadbalancing.amazonaws.com",
        "ec2.amazonaws.com",
        "ecs.amazonaws.com",
        "ecs-task.amazonaws.com",
        "ecr.amazonaws.com",
        "elasticache.amazonaws.com",
        "rds.amazonaws.com",
        "lambda.amazonaws.com",
        "efs.amazonaws.com",
        "s3.amazonaws.com",
        "ses.amazonaws.com",
        "sns.amazonaws.com",
        "ssm.amazonaws.com",
        "secretsmanager.amazonaws.com",
        "logs.amazonaws.com",
      ]
    }
  })

  tags = {
    Name = "${local.project}-${local.env}-ebd-ctl-check-api-calls"
  }
}

resource "aws_cloudwatch_event_target" "cloudtrail_check_api_calls" {
  rule      = aws_cloudwatch_event_rule.cloudtrail_check_api_calls.name
  target_id = aws_sns_topic.event_notifications_audit.name
  arn       = aws_sns_topic.event_notifications_audit.arn
}
