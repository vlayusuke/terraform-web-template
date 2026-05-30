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
# AWS KMS for Amazon Aurora
# ===============================================================================
resource "aws_kms_key" "aurora" {
  description             = "${local.project}-${local.env}-kms-aurora-key"
  enable_key_rotation     = true
  key_usage               = "ENCRYPT_DECRYPT"
  deletion_window_in_days = 7

  tags = {
    Name = "${local.project}-${local.env}-kms-aurora-key"
  }
}


# ===============================================================================
# AWS KMS for Amazon ElastCache
# ===============================================================================
resource "aws_kms_key" "elasticache" {
  description             = "${local.project}-${local.env}-kms-ec-key"
  enable_key_rotation     = true
  key_usage               = "ENCRYPT_DECRYPT"
  deletion_window_in_days = 7

  tags = {
    Name = "${local.project}-${local.env}-kms-ec-key"
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
# AWS KMS Key Policy for Application
# ===============================================================================
resource "aws_kms_key_policy" "application" {
  key_id = aws_kms_key.application.key_id
  policy = data.aws_iam_policy_document.application_kms_policy.json
}

data "aws_iam_policy_document" "application_kms_policy" {
  statement {
    sid    = "ApplicationAssume"
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
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
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:group/${local.iam_infra_group}",
      ]
    }
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
    sid    = "AuroraAssume"
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "Service"
      identifiers = [
        "rds.amazonaws.com",
      ]
    }
  }

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
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:group/${local.iam_infra_group}",
      ]
    }
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
    sid    = "ElasticacheAssume"
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "Service"
      identifiers = [
        "elasticache.amazonaws.com",
      ]
    }
  }

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
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:group/${local.iam_infra_group}",
      ]
    }
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
    sid    = "EFSAssume"
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "Service"
      identifiers = [
        "efs.amazonaws.com",
      ]
    }
  }

  statement {
    sid    = "EFSKMS"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
    ]
    resources = [
      aws_kms_key.efs.arn,
    ]
    principals {
      type = "Service"
      identifiers = [
        "efs.amazonaws.com",
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
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:group/${local.iam_infra_group}",
      ]
    }
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
    sid    = "EBSAssume"
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "Service"
      identifiers = [
        "ebs.amazonaws.com",
      ]
    }
  }

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
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:group/${local.iam_infra_group}",
      ]
    }
  }
}
