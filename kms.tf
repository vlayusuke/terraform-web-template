# ===============================================================================
# AWS KMS for AWS CodeCommit
# ===============================================================================
resource "aws_kms_key" "codecommit" {
  description             = "${local.project}-${local.env}-kms-cmt-key"
  enable_key_rotation     = true
  deletion_window_in_days = 7

  tags = {
    Name = "${local.project}-${local.env}-kms-cmt-key"
  }
}


# ===============================================================================
# AWS KMS Key Policy for AWS CodeCommit
# ===============================================================================
resource "aws_kms_key_policy" "codecommit" {
  key_id = aws_kms_key.codecommit.key_id
  policy = data.aws_iam_policy_document.codecommit.json
}

data "aws_iam_policy_document" "codecommit" {
  statement {
    sid    = "AllowCodeCommitAccess"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
    ]
    resources = [
      aws_kms_key.codecommit.arn,
    ]
    principals {
      type = "Service"
      identifiers = [
        "codecommit.amazonaws.com",
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
      aws_kms_key.codecommit.arn,
    ]
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
      ]
    }
  }
}
