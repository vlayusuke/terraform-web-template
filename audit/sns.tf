# ===============================================================================
# Amazon SNS Topic for Audit Event Notification
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
      "sns:GetTopicAttributes",
      "sns:SetTopicAttributes",
      "sns:AddPermission",
      "sns:RemovePermission",
      "sns:DeleteTopic",
      "sns:Subscribe",
      "sns:ListSubscriptionsByTopic",
      "sns:Receive",
    ]
    resources = [
      aws_sns_topic.event_notifications_audit.arn,
    ]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
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
        "cloudtrail.amazonaws.com",
        "events.amazonaws.com",
        "config.amazonaws.com",
        "chatbot.amazonaws.com",
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
    sid    = "SNSAccess"
    effect = "Allow"
    actions = [
      "sns:GetTopicAttributes",
      "sns:SetTopicAttributes",
      "sns:AddPermission",
      "sns:RemovePermission",
      "sns:DeleteTopic",
      "sns:Subscribe",
      "sns:ListSubscriptionsByTopic",
      "sns:Receive",
    ]
    resources = [
      aws_sns_topic.config_notifications.arn,
    ]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
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
      aws_sns_topic.config_notifications.arn,
    ]

    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com",
        "config.amazonaws.com",
        "chatbot.amazonaws.com",
      ]
    }
  }
}
