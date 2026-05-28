# ===============================================================================
# Amazon SNS Topic for Audit Event Notification (ap-northeast-1)
# ===============================================================================
resource "aws_sns_topic" "event_notifications_audit" {
  name = "${local.project}-${local.env}-sns-event-notifications"

  delivery_policy = jsonencode({
    "http" : {
      "defaultHealthyRetryPolicy" : {
        "minDelayTarget" : 20,
        "maxDelayTarget" : 20,
        "numRetries" : 3,
        "numMaxDelayRetries" : 0,
        "numNoDelayRetries" : 0,
        "numMinDelayRetries" : 0,
        "backoffFunction" : "linear"
      },
      "disableSubscriptionOverrides" : false
    }
  })

  tags = {
    Name = "${local.project}-${local.env}-sns-event-notifications"
  }
}

resource "aws_sns_topic_policy" "event_notifications_audit" {
  arn    = aws_sns_topic.event_notifications_audit.arn
  policy = data.aws_iam_policy_document.event_notifications_audit.json
}

data "aws_iam_policy_document" "event_notifications_audit" {
  statement {
    sid    = "SNSAccess"
    effect = "Allow"
    actions = [
      "sns:Publish",
      "sns:RemovePermission",
      "sns:SetTopicAttributes",
      "sns:DeleteTopic",
      "sns:ListSubscriptionsByTopic",
      "sns:GetTopicAttributes",
      "sns:AddPermission",
      "sns:Subscribe",
    ]
    resources = [
      aws_sns_topic.event_notifications_audit.arn,
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"
      values = [
        data.aws_caller_identity.current.account_id,
      ]
    }

    principals {
      type = "AWS"
      identifiers = [
        "*",
      ]
    }
  }

  statement {
    sid    = "SNSPublish"
    effect = "Allow"
    actions = [
      "sns:Publish",
    ]
    resources = [
      aws_sns_topic.event_notifications_audit.arn,
    ]
    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com",
      ]
    }
  }
}


# ===============================================================================
# Amazon SNS Topic for Audit Event Notification (us-east-1)
# ===============================================================================
resource "aws_sns_topic" "event_notifications_audit_global" {
  provider = aws.virginia
  name     = "${local.project}-${local.env}-sns-event-notifications-global"

  delivery_policy = jsonencode({
    "http" : {
      "defaultHealthyRetryPolicy" : {
        "minDelayTarget" : 20,
        "maxDelayTarget" : 20,
        "numRetries" : 3,
        "numMaxDelayRetries" : 0,
        "numNoDelayRetries" : 0,
        "numMinDelayRetries" : 0,
        "backoffFunction" : "linear"
      },
      "disableSubscriptionOverrides" : false
    }
  })

  tags = {
    Name = "${local.project}-${local.env}-sns-event-notifications-global"
  }
}

resource "aws_sns_topic_policy" "event_notifications_audit_global" {
  provider = aws.virginia
  arn      = aws_sns_topic.event_notifications_audit_global.arn
  policy   = data.aws_iam_policy_document.event_notifications_audit_global.json
}

data "aws_iam_policy_document" "event_notifications_audit_global" {
  statement {
    sid    = "SNSAccess"
    effect = "Allow"
    actions = [
      "sns:Publish",
      "sns:RemovePermission",
      "sns:SetTopicAttributes",
      "sns:DeleteTopic",
      "sns:ListSubscriptionsByTopic",
      "sns:GetTopicAttributes",
      "sns:AddPermission",
      "sns:Subscribe",
    ]
    resources = [
      aws_sns_topic.event_notifications_audit_global.arn,
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"
      values = [
        data.aws_caller_identity.current.account_id,
      ]
    }

    principals {
      type = "AWS"
      identifiers = [
        "*",
      ]
    }
  }

  statement {
    sid    = "SNSPublish"
    effect = "Allow"
    actions = [
      "sns:Publish",
    ]
    resources = [
      aws_sns_topic.event_notifications_audit_global.arn,
    ]
    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com",
      ]
    }
  }
}


# ===============================================================================
# Amazon SNS Topic for AWS Config Notification to Slack
# ===============================================================================
resource "aws_sns_topic" "config_notifications" {
  name = "${local.project}-${local.env}-sns-config-notifications"

  tags = {
    Name = "${local.project}-${local.env}-sns-config-notifications"
  }
}

resource "aws_sns_topic_policy" "config_notifications_policy" {
  arn    = aws_sns_topic.config_notifications.arn
  policy = data.aws_iam_policy_document.config_notifications_policy.json
}

data "aws_iam_policy_document" "config_notifications_policy" {
  statement {
    effect = "Allow"
    actions = [
      "sns:Publish",
    ]
    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com",
      ]
    }
    resources = [
      aws_sns_topic.config_notifications.arn,
    ]
  }
}
