# ===============================================================================
# Amazon EventBridge (Check Config)
# ===============================================================================
resource "aws_cloudwatch_event_rule" "check_config" {
  name           = "${local.project}-${local.env}-eb-check-config"
  description    = "Check Config Notification"
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
    Name = "${local.project}-${local.env}-eb-check-config"
  }
}

resource "aws_cloudwatch_event_target" "check_config" {
  rule      = aws_cloudwatch_event_rule.check_config.name
  target_id = aws_sns_topic.event_notification_audit.name
  arn       = aws_sns_topic.event_notification_audit.arn
}


# ===============================================================================
# Amazon EventBridge (Check Non Compliance)
# ===============================================================================
resource "aws_cloudwatch_event_rule" "config_non_compliance" {
  name           = "${local.project}-${local.env}-eb-config-non-compliance"
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
    Name = "${local.project}-${local.env}-eb-config-non-compliance"
  }
}

resource "aws_cloudwatch_event_target" "config_non_compliance" {
  rule      = aws_cloudwatch_event_rule.config_non_compliance.name
  target_id = aws_sns_topic.config_notifications.name
  arn       = aws_sns_topic.config_notifications.arn
}


# ===============================================================================
# Amazon EventBridge (AWS CloudTrail)
# ===============================================================================
resource "aws_cloudwatch_event_rule" "cloudtrail" {
  name           = "${local.project}-${local.env}-eb-cloudtrail"
  description    = "AWS CloudTrail Notification"
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
        "monitoring.amazonaws.com",
        "log.amazonaws.com",
        "ec2.amazonaws.com",
        "elasticloadbalancing.amazonaws.com",
        "iam.amazonaws.com",
        "lambda.amazonaws.com",
        "s3.amazonaws.com",
        "ses.amazonaws.com",
        "sns.amazonaws.com",
        "elasticache.amazonaws.com",
        "rds.amazonaws.com",
        "signin.amazonaws.com"
      ]
    }
  })

  tags = {
    Name = "${local.project}-${local.env}-eb-cloudtrail"
  }
}

resource "aws_cloudwatch_event_target" "cloudtrail" {
  rule      = aws_cloudwatch_event_rule.cloudtrail.name
  target_id = aws_sns_topic.event_notification_audit.name
  arn       = aws_sns_topic.event_notification_audit.arn
}
