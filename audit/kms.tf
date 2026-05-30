# ===============================================================================
# AWS KMS for AWS CloudTrail
# ===============================================================================
resource "aws_kms_key" "cloudtrail" {
  description             = "${local.project}-${local.env}-kms-ct-key"
  enable_key_rotation     = true
  key_usage               = "ENCRYPT_DECRYPT"
  deletion_window_in_days = 7

  tags = {
    Name = "${local.project}-${local.env}-kms-ct-key"
  }
}

resource "aws_kms_key_policy" "cloudtrail" {
  key_id = aws_kms_key.cloudtrail.key_id
  policy = data.aws_iam_policy_document.cloudtrail_kms_policy.json
}

data "aws_iam_policy_document" "cloudtrail_kms_policy" {
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

  statement {
    sid    = "CloudTrailKMS"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
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
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:group/${local.iam_infra_group}",
      ]
    }
  }
}
