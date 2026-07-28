# ===============================================================================
# AWS KMS for AWS CloudTrail
# ===============================================================================
resource "aws_kms_key" "cloudtrail" {
  description             = "${local.project}-${local.env}-kms-ctl-key"
  enable_key_rotation     = true
  key_usage               = "ENCRYPT_DECRYPT"
  deletion_window_in_days = 7

  tags = {
    Name = "${local.project}-${local.env}-kms-ctl-key"
  }
}


# ===============================================================================
# AWS KMS Key Policy for AWS CloudTrail
# ===============================================================================
resource "aws_kms_key_policy" "cloudtrail" {
  key_id = aws_kms_key.cloudtrail.key_id
  policy = data.aws_iam_policy_document.cloudtrail_kms_policy.json
}

data "aws_iam_policy_document" "cloudtrail_kms_policy" {
  statement {
    sid    = "CloudTrailKMS"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:GenerateDataKey*",
      "kms:ReEncrypt*",
      "kms:DescribeKey",
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:RevokeGrant",
    ]
    resources = [
      aws_kms_key.cloudtrail.arn,
    ]
    principals {
      type = "Service"
      identifiers = [
        "cloudtrail.amazonaws.com",
      ]
    }
  }

  statement {
    sid    = "AllowAccountAccess"
    effect = "Allow"
    actions = [
      "kms:*",
    ]
    resources = [
      aws_kms_key.cloudtrail.arn,
    ]
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
      ]
    }
  }
}


# ===============================================================================
# AWS KMS for Amazon GuardDuty
# ===============================================================================
resource "aws_kms_key" "guardduty" {
  description             = "${local.project}-${local.env}-kms-gdt-key"
  enable_key_rotation     = true
  key_usage               = "ENCRYPT_DECRYPT"
  deletion_window_in_days = 7

  tags = {
    Name = "${local.project}-${local.env}-kms-gdt-key"
  }
}


# ===============================================================================
# AWS KMS Key Policy for Amazon GuardDuty
# ===============================================================================
resource "aws_kms_key_policy" "guardduty" {
  key_id = aws_kms_key.guardduty.key_id
  policy = data.aws_iam_policy_document.guardduty_kms_policy.json
}

data "aws_iam_policy_document" "guardduty_kms_policy" {
  statement {
    sid    = "GuardDutyKMS"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:GenerateDataKey*",
      "kms:ReEncrypt*",
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:RevokeGrant",
      "kms:DescribeKey",
    ]
    resources = [
      aws_kms_key.guardduty.arn,
    ]
    principals {
      type = "Service"
      identifiers = [
        "guardduty.amazonaws.com",
      ]
    }
  }

  statement {
    sid    = "AllowAccountAccess"
    effect = "Allow"
    actions = [
      "kms:*",
    ]
    resources = [
      aws_kms_key.guardduty.arn,
    ]
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
      ]
    }
  }
}


# ===============================================================================
# AWS KMS for AWS Lambda
# ===============================================================================
resource "aws_kms_key" "lambda" {
  description             = "${local.project}-${local.env}-kms-lmd-key"
  enable_key_rotation     = true
  key_usage               = "ENCRYPT_DECRYPT"
  deletion_window_in_days = 7

  tags = {
    Name = "${local.project}-${local.env}-kms-lmd-key"
  }
}


# ===============================================================================
# AWS KMS Key Policy for AWS Lambda
# ===============================================================================
resource "aws_kms_key_policy" "lambda" {
  key_id = aws_kms_key.lambda.key_id
  policy = data.aws_iam_policy_document.lambda_kms_policy.json
}

data "aws_iam_policy_document" "lambda_kms_policy" {
  statement {
    sid    = "LambdaKMS"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
    ]
    resources = [
      aws_kms_key.lambda.arn,
    ]
    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com",
      ]
    }
  }

  statement {
    sid    = "AllowAccountAccess"
    effect = "Allow"
    actions = [
      "kms:*",
    ]
    resources = [
      aws_kms_key.lambda.arn,
    ]
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
      ]
    }
  }
}
