# ===============================================================================
# AWS KMS for Application
# ===============================================================================
resource "aws_kms_key" "application" {
  description             = "${local.project}-${local.env}-kms-application-key"
  enable_key_rotation     = true
  key_usage               = "ENCRYPT_DECRYPT"
  deletion_window_in_days = 7

  tags = {
    Name = "${local.project}-${local.env}-kms-application-key"
  }
}


# ===============================================================================
# AWS KMS Key Policy for Application
# ===============================================================================
resource "aws_kms_key_policy" "application" {
  key_id = aws_kms_key.application.key_id
  policy = data.aws_iam_policy_document.application_kms_policy.json
}

data "aws_iam_policy_document" "application_kms_policy" {
  statement {
    sid    = "ApplicationKMS"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
    ]
    resources = [
      aws_kms_key.application.arn,
    ]
    principals {
      type = "Service"
      identifiers = [
        "ecs.amazonaws.com",
        "ecs-tasks.amazonaws.com",
        "ec2.amazonaws.com",
        "secretsmanager.amazonaws.com",
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
      aws_kms_key.application.arn,
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
# AWS KMS for Amazon ECR
# ===============================================================================
resource "aws_kms_key" "ecr" {
  description             = "${local.project}-${local.env}-kms-ecr-key"
  enable_key_rotation     = true
  key_usage               = "ENCRYPT_DECRYPT"
  deletion_window_in_days = 7

  tags = {
    Name = "${local.project}-${local.env}-kms-ecr-key"
  }
}


# ===============================================================================
# AWS KMS Key Policy for Amazon ECR
# ===============================================================================
resource "aws_kms_key_policy" "ecr" {
  key_id = aws_kms_key.ecr.key_id
  policy = data.aws_iam_policy_document.ecr_kms_policy.json
}

data "aws_iam_policy_document" "ecr_kms_policy" {
  statement {
    sid    = "ECRKMS"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
    ]
    resources = [
      aws_kms_key.ecr.arn,
    ]
    principals {
      type = "Service"
      identifiers = [
        "ecr.amazonaws.com",
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
      aws_kms_key.ecr.arn,
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
# AWS KMS for Amazon Aurora
# ===============================================================================
resource "aws_kms_key" "aurora" {
  description             = "${local.project}-${local.env}-kms-aur-key"
  enable_key_rotation     = true
  key_usage               = "ENCRYPT_DECRYPT"
  deletion_window_in_days = 7

  tags = {
    Name = "${local.project}-${local.env}-kms-aur-key"
  }
}


# ===============================================================================
# AWS KMS Key Policy for Amazon Aurora
# ===============================================================================
resource "aws_kms_key_policy" "aurora" {
  key_id = aws_kms_key.aurora.key_id
  policy = data.aws_iam_policy_document.aurora_kms_policy.json
}

data "aws_iam_policy_document" "aurora_kms_policy" {
  statement {
    sid    = "AuroraKMS"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
    ]
    resources = [
      aws_kms_key.aurora.arn,
    ]
    principals {
      type = "Service"
      identifiers = [
        "rds.amazonaws.com",
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
      aws_kms_key.aurora.arn,
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
# AWS KMS for Amazon ElastCache
# ===============================================================================
resource "aws_kms_key" "elasticache" {
  description             = "${local.project}-${local.env}-kms-elc-key"
  enable_key_rotation     = true
  key_usage               = "ENCRYPT_DECRYPT"
  deletion_window_in_days = 7

  tags = {
    Name = "${local.project}-${local.env}-kms-elc-key"
  }
}


# ===============================================================================
# AWS KMS Key Policy for Amazon Elasticache
# ===============================================================================
resource "aws_kms_key_policy" "elasticache" {
  key_id = aws_kms_key.elasticache.key_id
  policy = data.aws_iam_policy_document.elasticache_kms_policy.json
}

data "aws_iam_policy_document" "elasticache_kms_policy" {
  statement {
    sid    = "ElasticacheKMS"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
    ]
    resources = [
      aws_kms_key.elasticache.arn,
    ]
    principals {
      type = "Service"
      identifiers = [
        "elasticache.amazonaws.com",
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
      aws_kms_key.elasticache.arn,
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
# AWS KMS for Amazon EFS
# ===============================================================================
resource "aws_kms_key" "efs" {
  description             = "${local.project}-${local.env}-kms-efs-key"
  enable_key_rotation     = true
  key_usage               = "ENCRYPT_DECRYPT"
  deletion_window_in_days = 7

  tags = {
    Name = "${local.project}-${local.env}-kms-efs-key"
  }
}


# ===============================================================================
# AWS KMS Key Policy for Amazon EFS
# ===============================================================================
resource "aws_kms_key_policy" "efs" {
  key_id = aws_kms_key.efs.key_id
  policy = data.aws_iam_policy_document.efs_kms_policy.json
}

data "aws_iam_policy_document" "efs_kms_policy" {
  statement {
    sid    = "EFSKMS"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:CreateGrant",
      "kms:DescribeKey",
    ]
    resources = [
      "*",
    ]
    principals {
      type = "AWS"
      identifiers = [
        "*",
      ]
    }
    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values = [
        "elasticfilesystem.${local.region}.amazonaws.com",
      ]
    }
    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values = [
        data.aws_caller_identity.current.account_id,
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
      aws_kms_key.efs.arn,
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
# AWS KMS for Amazon EBS
# ===============================================================================
resource "aws_kms_key" "ebs" {
  description             = "${local.project}-${local.env}-kms-ebs-key"
  enable_key_rotation     = true
  key_usage               = "ENCRYPT_DECRYPT"
  deletion_window_in_days = 7

  tags = {
    Name = "${local.project}-${local.env}-kms-ebs-key"
  }
}


# ===============================================================================
# AWS KMS Key Policy for Amazon EBS
# ===============================================================================
resource "aws_kms_key_policy" "ebs" {
  key_id = aws_kms_key.ebs.key_id
  policy = data.aws_iam_policy_document.ebs_kms_policy.json
}

data "aws_iam_policy_document" "ebs_kms_policy" {
  statement {
    sid    = "EBSKMS"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
    ]
    resources = [
      aws_kms_key.ebs.arn,
    ]
    principals {
      type = "Service"
      identifiers = [
        "ebs.amazonaws.com",
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
      aws_kms_key.ebs.arn,
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
# AWS KMS for Amazon CloudWatch Synthetics
# ===============================================================================
resource "aws_kms_key" "synthetics" {
  description             = "${local.project}-${local.env}-kms-cwt-syn-key"
  enable_key_rotation     = true
  key_usage               = "ENCRYPT_DECRYPT"
  deletion_window_in_days = 7

  tags = {
    Name = "${local.project}-${local.env}-kms-cwt-syn-key"
  }
}


# ===============================================================================
# AWS KMS Key Policy for Amazon CloudWatch Synthetics
# ===============================================================================
resource "aws_kms_key_policy" "synthetics" {
  key_id = aws_kms_key.synthetics.key_id
  policy = data.aws_iam_policy_document.synthetics_kms_policy.json
}

data "aws_iam_policy_document" "synthetics_kms_policy" {
  statement {
    sid    = "SyntheticsKMS"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
    ]
    resources = [
      aws_kms_key.synthetics.arn,
    ]
    principals {
      type = "Service"
      identifiers = [
        "synthetics.amazonaws.com",
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
      aws_kms_key.synthetics.arn,
    ]
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
      ]
    }
  }
}
