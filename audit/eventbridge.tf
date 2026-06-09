# ===============================================================================
# Amazon EventBridge (Check Config)
# ===============================================================================
resource "aws_cloudwatch_event_rule" "check_config" {
  name           = "${local.project}-${local.env}-ebd-check-config"
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
    Name = "${local.project}-${local.env}-ebd-check-config"
  }
}

resource "aws_cloudwatch_event_target" "check_config" {
  rule      = aws_cloudwatch_event_rule.check_config.name
  target_id = aws_sns_topic.event_notifications_audit.name
  arn       = aws_sns_topic.event_notifications_audit.arn
}


# ===============================================================================
# Amazon EventBridge (Check Non Compliance)
# ===============================================================================
resource "aws_cloudwatch_event_rule" "config_non_compliance" {
  name           = "${local.project}-${local.env}-ebd-config-non-compliance"
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
    Name = "${local.project}-${local.env}-ebd-config-non-compliance"
  }
}

resource "aws_cloudwatch_event_target" "config_non_compliance" {
  rule      = aws_cloudwatch_event_rule.config_non_compliance.name
  target_id = aws_sns_topic.config_notifications.name
  arn       = aws_sns_topic.config_notifications.arn
}


# ===============================================================================
# Amazon EventBridge (AWS CloudTrail / ap-northeast-1)
# ===============================================================================
resource "aws_cloudwatch_event_rule" "cloudtrail" {
  name           = "${local.project}-${local.env}-ebd-ctr"
  description    = "AWS CloudTrail Notification for ap-northeast-1"
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
        "ec2.amazonaws.com",
        "ecr.amazonaws.com",
        "ecs.amazonaws.com",
        "ecs-tasks.amazonaws.com",
        "elasticloadbalancing.amazonaws.com",
        "elasticache.amazonaws.com",
        "rds.amazonaws.com",
        "lambda.amazonaws.com",
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
    Name = "${local.project}-${local.env}-ebd-ctr"
  }
}

resource "aws_cloudwatch_event_target" "cloudtrail" {
  rule      = aws_cloudwatch_event_rule.cloudtrail.name
  target_id = aws_sns_topic.event_notifications_audit.name
  arn       = aws_sns_topic.event_notifications_audit.arn
}


# ===============================================================================
# Amazon EventBridge (AWS CloudTrail / us-east-1)
# ===============================================================================
resource "aws_cloudwatch_event_rule" "cloudtrail_global" {
  provider       = aws.virginia
  name           = "${local.project}-${local.env}-ebd-ctr-global"
  description    = "AWS CloudTrail Notification for us-east-1"
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
        "cloudfront.amazonaws.com",
        "wafv2.amazonaws.com",
        "route53.amazonaws.com",
        "lambda.amazonaws.com",
        "s3.amazonaws.com",
        "sns.amazonaws.com",
        "logs.amazonaws.com",
      ]
    }
  })

  tags = {
    Name = "${local.project}-${local.env}-ebd-ctr-global"
  }
}

resource "aws_cloudwatch_event_target" "cloudtrail_global" {
  provider  = aws.virginia
  rule      = aws_cloudwatch_event_rule.cloudtrail_global.name
  target_id = aws_sns_topic.event_notifications_audit_global.name
  arn       = aws_sns_topic.event_notifications_audit_global.arn
}
