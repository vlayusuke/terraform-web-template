# ===============================================================================
# AWS IAM for AWS Lambda (CloudWatch Error Alert)
# ===============================================================================
resource "aws_iam_role" "lambda_cloudwatch_audit" {
  name               = "${local.project}-${local.env}-iam-lmd-cwt-logs-error-alert-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.lambda_cloudwatch_audit_assume.json

  tags = {
    Name = "${local.project}-${local.env}-iam-lmd-cwt-logs-error-alert-role"
  }
}

data "aws_iam_policy_document" "lambda_cloudwatch_audit_assume" {
  statement {
    sid    = "LambdaAssume"
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_policy" "lambda_cloudwatch_audit" {
  name   = "${local.project}-${local.env}-iam-lmd-cwt-logs-error-alert-policy"
  policy = data.aws_iam_policy_document.lambda_cloudwatch_audit.json
  tags = {
    Name = "${local.project}-${local.env}-iam-lmd-cwt-logs-error-alert-policy"
  }
}

data "aws_iam_policy_document" "lambda_cloudwatch_audit" {
  statement {
    sid    = "LogAccess"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      "arn:aws:logs:${local.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${local.project}-${local.env}-*:*",
    ]
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
  }
}

resource "aws_iam_role_policy_attachment" "lambda_cloudwatch_audit" {
  role       = aws_iam_role.lambda_cloudwatch_audit.name
  policy_arn = aws_iam_policy.lambda_cloudwatch_audit.arn
}


# ===============================================================================
# AWS IAM for AWS Lambda (Root Login Monitoring)
# ===============================================================================
resource "aws_iam_role" "lambda_root_login_monitoring" {
  name               = "${local.project}-${local.env}-iam-lmd-root-login-monitoring-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.lambda_root_login_monitoring_assume.json

  tags = {
    Name = "${local.project}-${local.env}-iam-lmd-root-login-monitoring-role"
  }
}

data "aws_iam_policy_document" "lambda_root_login_monitoring_assume" {
  statement {
    sid    = "LambdaAssume"
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_policy" "lambda_root_login_monitoring" {
  name   = "${local.project}-${local.env}-iam-lmd-root-login-monitoring-policy"
  policy = data.aws_iam_policy_document.lambda_root_login_monitoring.json

  tags = {
    Name = "${local.project}-${local.env}-iam-lmd-root-login-monitoring-policy"
  }
}

data "aws_iam_policy_document" "lambda_root_login_monitoring" {
  statement {
    sid    = "GenerateLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      "arn:aws:logs:*:*:log-group:*",
    ]
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
  }
}

resource "aws_iam_role_policy_attachment" "lambda_root_login_monitoring" {
  role       = aws_iam_role.lambda_root_login_monitoring.name
  policy_arn = aws_iam_policy.lambda_root_login_monitoring.arn
}


# ===============================================================================
# AWS IAM for AWS Lambda (Lambda Error)
# ===============================================================================
resource "aws_iam_role" "lambda_error" {
  name               = "${local.project}-${local.env}-iam-lmd-error-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.lambda_error_assume.json

  tags = {
    Name = "${local.project}-${local.env}-iam-lmd-error-role"
  }
}

data "aws_iam_policy_document" "lambda_error_assume" {
  statement {
    sid    = "LambdaAssume"
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_policy" "lambda_error" {
  name   = "${local.project}-${local.env}-iam-lmd-error-policy"
  policy = data.aws_iam_policy_document.lambda_error.json

  tags = {
    Name = "${local.project}-${local.env}-iam-lmd-error-policy"
  }
}

data "aws_iam_policy_document" "lambda_error" {
  statement {
    sid    = "GenerateLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:PutLogEvents",
    ]
    resources = [
      "arn:aws:logs:${local.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${local.project}-${local.env}-*:*",
    ]
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
  }
}

resource "aws_iam_role_policy_attachment" "lambda_error" {
  role       = aws_iam_role.lambda_error.name
  policy_arn = aws_iam_policy.lambda_error.arn
}


# ===============================================================================
# AWS IAM for AWS Lambda (Security Notice)
# ===============================================================================
resource "aws_iam_role" "lambda_security_notice" {
  name               = "${local.project}-${local.env}-iam-lmd-security-notice-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.lambda_security_notice_assume.json

  tags = {
    Name = "${local.project}-${local.env}-iam-lmd-security-notice-role"
  }
}

data "aws_iam_policy_document" "lambda_security_notice_assume" {
  statement {
    sid    = "LambdaAssume"
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_policy" "lambda_security_notice" {
  name   = "${local.project}-${local.env}-iam-lmd-security-notice-policy"
  policy = data.aws_iam_policy_document.lambda_security_notice.json

  tags = {
    Name = "${local.project}-${local.env}-iam-lmd-security-notice-policy"
  }
}

data "aws_iam_policy_document" "lambda_security_notice" {
  statement {
    sid    = "GenerateLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:PutLogEvents",
    ]
    resources = [
      "arn:aws:logs:${local.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${local.project}-${local.env}-*:*",
    ]
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
  }
}

resource "aws_iam_role_policy_attachment" "security_notice" {
  role       = aws_iam_role.lambda_security_notice.name
  policy_arn = aws_iam_policy.lambda_security_notice.arn
}


# ===============================================================================
# AWS IAM for AWS Chatbot
# ===============================================================================
resource "aws_iam_role" "chatbot_audit" {
  name               = "${local.project}-${local.env}-iam-chatbot-role"
  assume_role_policy = data.aws_iam_policy_document.chatbot_audit_assume.json

  tags = {
    Name = "${local.project}-${local.env}-iam-chatbot-role"
  }
}

data "aws_iam_policy_document" "chatbot_audit_assume" {
  statement {
    sid    = "ChatbotAssume"
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "Service"
      identifiers = [
        "chatbot.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_policy" "chatbot_audit" {
  name   = "${local.project}-${local.env}-iam-chatbot-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.chatbot_audit.json

  tags = {
    Name = "${local.project}-${local.env}-iam-chatbot-policy"
  }
}

data "aws_iam_policy_document" "chatbot_audit" {
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
      "sns:Unsubscribe",
      "sns:ListTopics",
      "sns:ListSubscriptions",
      "sns:ListSubscriptionsByTopic",
      "sns:Publish",
    ]
    resources = [
      "*",
    ]
  }

  statement {
    sid    = "LogAccess"
    effect = "Allow"
    actions = [
      "logs:PutLogEvents",
      "logs:CreateLogStream",
      "logs:DescribeLogStreams",
      "logs:CreateLogGroup",
      "logs:DescribeLogGroups",
    ]
    resources = [
      "arn:aws:logs:*:*:log-group:/aws/chatbot/*",
    ]
  }

  statement {
    sid    = "SNSPublish"
    effect = "Allow"
    actions = [
      "sns:Publish",
      "sns:Subscribe",
    ]
    resources = [
      aws_sns_topic.event_notifications_audit.arn,
    ]
  }

  statement {
    sid    = "ChatbotAccess"
    effect = "Allow"
    actions = [
      "chatbot:CreateSlackChannelConfiguration",
      "chatbot:DescribeSlackChannelConfigurations",
      "chatbot:DeleteSlackChannelConfiguration",
      "chatbot:UpdateSlackChannelConfiguration",
    ]
    resources = [
      "*",
    ]
  }
}

resource "aws_iam_role_policy_attachment" "chatbot_audit" {
  role       = aws_iam_role.chatbot_audit.name
  policy_arn = aws_iam_policy.chatbot_audit.arn
}

resource "aws_iam_role_policy_attachment" "chatbot_audit_resource_read_only_access" {
  role       = aws_iam_role.chatbot_audit.name
  policy_arn = "arn:aws:iam::aws:policy/AWSResourceExplorerReadOnlyAccess"
}


# ===============================================================================
# AWS IAM for AWS Chatbot Guardrail
# ===============================================================================
resource "aws_iam_policy" "chatbot_audit_guardrail" {
  name   = "${local.project}-${local.env}-iam-chatbot-guardrail-policy"
  policy = data.aws_iam_policy_document.chatbot_audit_guardrail.json

  tags = {
    Name = "${local.project}-${local.env}-iam-chatbot-guardrail-policy"
  }
}

data "aws_iam_policy_document" "chatbot_audit_guardrail" {
  statement {
    sid    = "ChatbotAccess"
    effect = "Allow"
    actions = [
      "chatbot:DescribeSlackChannelConfigurations",
      "chatbot:DescribeSlackWorkspaceAuthorizations",
    ]
    resources = [
      "*",
    ]
  }
}


# ===============================================================================
# AWS IAM for AWS Config
# ===============================================================================
resource "aws_iam_role" "config" {
  name               = "${local.project}-${local.env}-iam-cfg-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.config_assume.json

  tags = {
    Name = "${local.project}-${local.env}-iam-cfg-role"
  }
}

data "aws_iam_policy_document" "config_assume" {
  statement {
    sid    = "ConfigAssume"
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "Service"
      identifiers = [
        "config.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_policy" "config" {
  name   = "${local.project}-${local.env}-iam-cfg-policy"
  policy = data.aws_iam_policy_document.config.json

  tags = {
    Name = "${local.project}-${local.env}-iam-cfg-policy"
  }
}

data "aws_iam_policy_document" "config" {
  statement {
    sid    = "S3Access"
    effect = "Allow"
    actions = [
      "s3:GetBucketAcl",
      "s3:PutObject",
      "s3:PutObjectAcl",
    ]
    resources = [
      aws_s3_bucket.config_logs.arn,
      "${aws_s3_bucket.config_logs.arn}/*",
    ]
  }

  statement {
    sid    = "ConfigAccess"
    effect = "Allow"
    actions = [
      "config:DescribeConfigurationRecorders",
      "config:DeleteConfigurationRecorder",
    ]
    resources = [
      "*",
    ]
  }

  statement {
    sid    = "CloudTrailAccess"
    effect = "Allow"
    actions = [
      "cloudtrail:Get*",
      "cloudtrail:Describe*",
    ]
    resources = [
      "*",
    ]
  }

  statement {
    sid    = "SNSPublish"
    effect = "Allow"
    actions = [
      "sns:Publish",
      "sns:Subscribe",
    ]
    resources = [
      aws_sns_topic.event_notifications_audit.arn,
    ]
  }
}

resource "aws_iam_role_policy_attachment" "config" {
  role       = aws_iam_role.config.name
  policy_arn = aws_iam_policy.config.arn
}

resource "aws_iam_role_policy_attachment" "config_to_aws_config_role" {
  role       = aws_iam_role.config.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}


# ===============================================================================
# AWS IAM for AWS CloudTrail
# ===============================================================================
resource "aws_iam_role" "cloudtrail" {
  name               = "${local.project}-${local.env}-iam-ctl-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.cloudtrail_assume.json

  tags = {
    Name = "${local.project}-${local.env}-iam-ctl-role"
  }
}

data "aws_iam_policy_document" "cloudtrail_assume" {
  statement {
    sid    = "CloudTrailAssume"
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "Service"
      identifiers = [
        "cloudtrail.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_policy" "cloudtrail" {
  name   = "${local.project}-${local.env}-iam-ctl-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.cloudtrail.json

  tags = {
    Name = "${local.project}-${local.env}-iam-ctl-policy"
  }
}

data "aws_iam_policy_document" "cloudtrail" {
  statement {
    sid    = "S3Access"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:GetBucketAcl",
    ]
    resources = [
      aws_s3_bucket.cloudtrail_logs.arn,
      "${aws_s3_bucket.cloudtrail_logs.arn}/*",
    ]
  }

  statement {
    sid    = "LogAccess"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      aws_cloudwatch_log_group.cloudtrail.arn,
      "${aws_cloudwatch_log_group.cloudtrail.arn}:*",
    ]
  }
}

resource "aws_iam_role_policy_attachment" "cloudtrail" {
  role       = aws_iam_role.cloudtrail.name
  policy_arn = aws_iam_policy.cloudtrail.arn
}


# ===============================================================================
# AWS IAM for Amazon SNS
# ===============================================================================
resource "aws_iam_role" "sns" {
  name               = "${local.project}-${local.env}-iam-sns-role"
  assume_role_policy = data.aws_iam_policy_document.sns_assume.json

  tags = {
    Name = "${local.project}-${local.env}-iam-sns-role"
  }
}

data "aws_iam_policy_document" "sns_assume" {
  statement {
    sid    = "SNSAssume"
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "Service"
      identifiers = [
        "sns.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_policy" "sns" {
  name   = "${local.project}-${local.env}-iam-sns-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.sns.json

  tags = {
    Name = "${local.project}-${local.env}-iam-sns-policy"
  }
}

data "aws_iam_policy_document" "sns" {
  statement {
    sid    = "DescribeLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      aws_cloudwatch_log_group.sns.arn,
      "${aws_cloudwatch_log_group.sns.arn}:*",
    ]
  }

  statement {
    sid    = "SNSSubscribe"
    effect = "Allow"
    actions = [
      "sns:Subscribe",
    ]
    resources = [
      aws_sns_topic.event_notifications_audit.arn,
    ]
  }
}

resource "aws_iam_role_policy_attachment" "sns" {
  role       = aws_iam_role.sns.name
  policy_arn = aws_iam_policy.sns.arn
}


# ===============================================================================
# AWS IAM for Amazon SNS via Amazon EventBridge
# ===============================================================================
resource "aws_iam_role" "eventbridge_to_sns" {
  name               = "${local.project}-${local.env}-iam-ebd-to-sns-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.eventbridge_to_sns_assume.json

  tags = {
    Name = "${local.project}-${local.env}-iam-ebd-to-sns-role"
  }
}

data "aws_iam_policy_document" "eventbridge_to_sns_assume" {
  statement {
    sid    = "EventAssume"
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_policy" "eventbridge_to_sns_policy" {
  name   = "${local.project}-${local.env}-iam-ebd-to-sns-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.eventbridge_to_sns_policy.json

  tags = {
    Name = "${local.project}-${local.env}-iam-ebd-to-sns-policy"
  }
}

data "aws_iam_policy_document" "eventbridge_to_sns_policy" {
  statement {
    sid    = "SNSPublish"
    effect = "Allow"
    actions = [
      "sns:Publish",
    ]
    resources = [
      aws_sns_topic.config_notifications.arn,
    ]
  }
}

resource "aws_iam_role_policy_attachment" "eventbridge_to_sns_policy" {
  role       = aws_iam_role.eventbridge_to_sns.name
  policy_arn = aws_iam_policy.eventbridge_to_sns_policy.arn
}
