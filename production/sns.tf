# ===============================================================================
# Amazon SNS Topic for Metric Alarm
# ===============================================================================
resource "aws_sns_topic" "metric_alarm" {
  name                             = "${local.project}-${local.env}-sns-metric-alarm-topic"
  display_name                     = "Amazon SNS Topic for Metric Alarm"
  lambda_success_feedback_role_arn = aws_iam_role.lambda_cloudwatch.arn
  lambda_failure_feedback_role_arn = aws_iam_role.lambda_cloudwatch.arn
  signature_version                = "SignatureVersion2"

  delivery_policy = jsonencode({
    "http" : {
      "defaultHealthyRetryPolicy" : {
        "minDelayTarget" : 10,
        "maxDelayTarget" : 30,
        "numRetries" : 5,
        "numMaxDelayRetries" : 0,
        "numNoDelayRetries" : 0,
        "numMinDelayRetries" : 0,
        "backoffFunction" : "linear"
      },
      "disableSubscriptionOverrides" : false
    }
  })

  tags = {
    Name = "${local.project}-${local.env}-sns-metric-alarm-topic"
  }
}

resource "aws_sns_topic_policy" "metric_alarm" {
  arn    = aws_sns_topic.metric_alarm.arn
  policy = data.aws_iam_policy_document.metric_alarm.json
}

data "aws_iam_policy_document" "metric_alarm" {
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
      aws_sns_topic.metric_alarm.arn,
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
      aws_sns_topic.metric_alarm.arn,
    ]
    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com",
        "chatbot.amazonaws.com",
      ]
    }
  }
}


# ===============================================================================
# Amazon SNS Topic for Event Alarm
# ===============================================================================
resource "aws_sns_topic" "event_alarm" {
  name                             = "${local.project}-${local.env}-sns-event-alarm-topic"
  display_name                     = "Amazon SNS Topic for Event Alarm"
  lambda_success_feedback_role_arn = aws_iam_role.lambda_cloudwatch.arn
  lambda_failure_feedback_role_arn = aws_iam_role.lambda_cloudwatch.arn
  signature_version                = "SignatureVersion2"

  delivery_policy = jsonencode({
    "http" : {
      "defaultHealthyRetryPolicy" : {
        "minDelayTarget" : 10,
        "maxDelayTarget" : 30,
        "numRetries" : 5,
        "numMaxDelayRetries" : 0,
        "numNoDelayRetries" : 0,
        "numMinDelayRetries" : 0,
        "backoffFunction" : "linear"
      },
      "disableSubscriptionOverrides" : false
    }
  })

  tags = {
    Name = "${local.project}-${local.env}-sns-event-alarm-topic"
  }
}

resource "aws_sns_topic_policy" "event_alarm" {
  arn    = aws_sns_topic.event_alarm.arn
  policy = data.aws_iam_policy_document.event_alarm.json
}

data "aws_iam_policy_document" "event_alarm" {
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
      aws_sns_topic.event_alarm.arn,
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
      aws_sns_topic.event_alarm.arn,
    ]
    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com",
        "chatbot.amazonaws.com",
      ]
    }
  }
}


# ===============================================================================
# Amazon SNS Topic for Amazon Inspector Notifications
# ===============================================================================
resource "aws_sns_topic" "inspector_notifications" {
  name                             = "${local.project}-${local.env}-sns-inspector-notifications-topic"
  display_name                     = "Amazon SNS Topic for Amazon Inspector Notifications"
  lambda_success_feedback_role_arn = aws_iam_role.lambda_cloudwatch.arn
  lambda_failure_feedback_role_arn = aws_iam_role.lambda_cloudwatch.arn
  signature_version                = "SignatureVersion2"

  delivery_policy = jsonencode({
    "http" : {
      "defaultHealthyRetryPolicy" : {
        "minDelayTarget" : 10,
        "maxDelayTarget" : 30,
        "numRetries" : 5,
        "numMaxDelayRetries" : 0,
        "numNoDelayRetries" : 0,
        "numMinDelayRetries" : 0,
        "backoffFunction" : "linear"
      },
      "disableSubscriptionOverrides" : false
    }
  })

  tags = {
    Name = "${local.project}-${local.env}-sns-inspector-notifications-topic"
  }
}

resource "aws_sns_topic_policy" "inspector_notifications" {
  arn    = aws_sns_topic.inspector_notifications.arn
  policy = data.aws_iam_policy_document.inspector_notifications.json
}

data "aws_iam_policy_document" "inspector_notifications" {
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
      aws_sns_topic.inspector_notifications.arn,
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
      aws_sns_topic.inspector_notifications.arn,
    ]
    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com",
        "chatbot.amazonaws.com",
      ]
    }
  }
}


# ===============================================================================
# Amazon SNS Topic for Event Notifications
# ===============================================================================
resource "aws_sns_topic" "event_notifications" {
  name                             = "${local.project}-${local.env}-sns-event-notifications-topic"
  display_name                     = "Amazon SNS Topic for Event Notifications"
  lambda_success_feedback_role_arn = aws_iam_role.lambda_cloudwatch.arn
  lambda_failure_feedback_role_arn = aws_iam_role.lambda_cloudwatch.arn
  signature_version                = "SignatureVersion2"

  delivery_policy = jsonencode({
    "http" : {
      "defaultHealthyRetryPolicy" : {
        "minDelayTarget" : 10,
        "maxDelayTarget" : 30,
        "numRetries" : 5,
        "numMaxDelayRetries" : 0,
        "numNoDelayRetries" : 0,
        "numMinDelayRetries" : 0,
        "backoffFunction" : "linear"
      },
      "disableSubscriptionOverrides" : false
    }
  })

  tags = {
    Name = "${local.project}-${local.env}-sns-event-notifications-topic"
  }
}

resource "aws_sns_topic_policy" "event_notifications" {
  arn    = aws_sns_topic.event_notifications.arn
  policy = data.aws_iam_policy_document.event_notifications.json
}

data "aws_iam_policy_document" "event_notifications" {
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
      aws_sns_topic.event_notifications.arn,
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
      aws_sns_topic.event_notifications.arn,
    ]
    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com",
        "chatbot.amazonaws.com",
      ]
    }
  }
}
