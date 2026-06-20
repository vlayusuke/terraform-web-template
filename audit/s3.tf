# ===============================================================================
# Amazon S3 Bucket for AWS CloudTrail
# ===============================================================================
resource "aws_s3_bucket" "cloudtrail_logs" {
  bucket = "${local.project}-${local.env}-${local.account_id}-s3-ctl-logs-bucket"

  tags = {
    Name = "${local.project}-${local.env}-${local.account_id}-s3-ctl-logs-bucket"
  }
}

resource "aws_s3_bucket_ownership_controls" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id
  acl    = "log-delivery-write"

  depends_on = [
    aws_s3_bucket_ownership_controls.cloudtrail_logs,
  ]
}

resource "aws_s3_bucket_public_access_block" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.bucket

  rule {
    blocked_encryption_types = [
      "SSE-C"
    ]
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = false
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  rule {
    id     = "delete-object"
    status = "Enabled"

    filter {
      object_size_greater_than = 0
    }

    expiration {
      days = local.expire_days
    }

    noncurrent_version_expiration {
      noncurrent_days = local.expire_days
    }
  }

  depends_on = [
    aws_s3_bucket_versioning.cloudtrail_logs,
  ]
}

resource "aws_s3_bucket_versioning" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  target_bucket = aws_s3_bucket.s3_logs.id
  target_prefix = "cloudtrail-logs/"

}

resource "aws_s3_bucket_policy" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id
  policy = data.aws_iam_policy_document.cloudtrail_logs.json
}

data "aws_iam_policy_document" "cloudtrail_logs" {
  statement {
    sid    = "AWSCloudTrailAclCheck"
    effect = "Allow"
    actions = [
      "s3:GetBucketAcl",
      "s3:ListBucket",
      "s3:GetBucketLocation",
    ]
    resources = [
      aws_s3_bucket.cloudtrail_logs.arn,
    ]

    principals {
      type = "Service"
      identifiers = [
        "cloudtrail.amazonaws.com",
      ]
    }
  }

  statement {
    sid    = "AWSCloudTrailWrite"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
    ]
    resources = [
      "${aws_s3_bucket.cloudtrail_logs.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
    ]

    principals {
      type = "Service"
      identifiers = [
        "cloudtrail.amazonaws.com",
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values = [
        "bucket-owner-full-control",
      ]
    }
  }

  statement {
    sid    = "EnforceSSL"
    effect = "Deny"
    actions = [
      "s3:*",
    ]
    resources = [
      aws_s3_bucket.cloudtrail_logs.arn,
      "${aws_s3_bucket.cloudtrail_logs.arn}/*",
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values = [
        "false",
      ]
    }

    principals {
      type = "AWS"
      identifiers = [
        "*",
      ]
    }
  }
}


# ===============================================================================
# Amazon S3 Bucket for AWS Config
# ===============================================================================
resource "aws_s3_bucket" "config_logs" {
  bucket = "${local.project}-${local.env}-${local.account_id}-s3-cfg-logs-bucket"

  tags = {
    Name = "${local.project}-${local.env}-${local.account_id}-s3-cfg-logs-bucket"
  }
}

resource "aws_s3_bucket_ownership_controls" "config_logs" {
  bucket = aws_s3_bucket.config_logs.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "config_logs" {
  bucket = aws_s3_bucket.config_logs.id
  acl    = "log-delivery-write"

  depends_on = [
    aws_s3_bucket_ownership_controls.config_logs,
  ]
}

resource "aws_s3_bucket_public_access_block" "config_logs" {
  bucket = aws_s3_bucket.config_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "config_logs" {
  bucket = aws_s3_bucket.config_logs.bucket

  rule {
    blocked_encryption_types = [
      "SSE-C"
    ]
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = false
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "config_logs" {
  bucket = aws_s3_bucket.config_logs.id

  rule {
    id     = "delete-object"
    status = "Enabled"

    filter {
      object_size_greater_than = 0
    }

    expiration {
      days = local.expire_days
    }

    noncurrent_version_expiration {
      noncurrent_days = local.expire_days
    }
  }

  depends_on = [
    aws_s3_bucket_versioning.config_logs,
  ]
}

resource "aws_s3_bucket_versioning" "config_logs" {
  bucket = aws_s3_bucket.config_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "config_logs" {
  bucket = aws_s3_bucket.config_logs.id

  target_bucket = aws_s3_bucket.s3_logs.id
  target_prefix = "config-logs/"

}

resource "aws_s3_bucket_policy" "config_logs" {
  bucket = aws_s3_bucket.config_logs.id
  policy = data.aws_iam_policy_document.config_logs.json
}

data "aws_iam_policy_document" "config_logs" {
  statement {
    sid    = "EnforceSSL"
    effect = "Deny"
    actions = [
      "s3:*",
    ]
    resources = [
      aws_s3_bucket.config_logs.arn,
      "${aws_s3_bucket.config_logs.arn}/*",
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values = [
        "false",
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
    sid    = "AWSConfigBucketPermissionsCheck"
    effect = "Allow"
    actions = [
      "s3:GetBucketAcl",
    ]
    resources = [
      aws_s3_bucket.config_logs.arn,
    ]

    principals {
      type = "Service"
      identifiers = [
        "config.amazonaws.com",
      ]
    }
  }

  statement {
    sid    = "AWSConfigBucketExistenceCheck"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
    ]
    resources = [
      aws_s3_bucket.config_logs.arn,
    ]

    principals {
      type = "Service"
      identifiers = [
        "config.amazonaws.com",
      ]
    }
  }

  statement {
    sid    = "AWSConfigBucketDelivery"
    effect = "Allow"
    actions = [
      "s3:PutObject",
    ]
    resources = [
      "${aws_s3_bucket.config_logs.arn}/*",
    ]

    principals {
      type = "Service"
      identifiers = [
        "config.amazonaws.com",
      ]
    }
  }
}


# ===============================================================================
# Amazon S3 Bucket for Amazon GuardDuty Logs
# ===============================================================================
resource "aws_s3_bucket" "guardduty_logs" {
  bucket = "${local.project}-${local.env}-${local.account_id}-s3-gdt-logs-bucket"

  tags = {
    Name = "${local.project}-${local.env}-${local.account_id}-s3-gdt-logs-bucket"
  }
}

resource "aws_s3_bucket_ownership_controls" "guardduty_logs" {
  bucket = aws_s3_bucket.guardduty_logs.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "guardduty_logs" {
  bucket = aws_s3_bucket.guardduty_logs.id
  acl    = "log-delivery-write"

  depends_on = [
    aws_s3_bucket_ownership_controls.guardduty_logs,
  ]
}

resource "aws_s3_bucket_public_access_block" "guardduty_logs" {
  bucket = aws_s3_bucket.guardduty_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "guardduty_logs" {
  bucket = aws_s3_bucket.guardduty_logs.bucket

  rule {
    blocked_encryption_types = [
      "SSE-C"
    ]
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = false
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "guardduty_logs" {
  bucket = aws_s3_bucket.guardduty_logs.id

  rule {
    id     = "delete-object"
    status = "Enabled"

    filter {
      object_size_greater_than = 0
    }

    expiration {
      days = local.expire_days
    }

    noncurrent_version_expiration {
      noncurrent_days = local.expire_days
    }
  }

  depends_on = [
    aws_s3_bucket_versioning.guardduty_logs,
  ]
}

resource "aws_s3_bucket_versioning" "guardduty_logs" {
  bucket = aws_s3_bucket.guardduty_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "guardduty_logs" {
  bucket = aws_s3_bucket.guardduty_logs.id

  target_bucket = aws_s3_bucket.s3_logs.id
  target_prefix = "guardduty-logs/"

}

resource "aws_s3_bucket_policy" "guardduty_logs" {
  bucket = aws_s3_bucket.guardduty_logs.id
  policy = data.aws_iam_policy_document.guardduty_logs.json
}

data "aws_iam_policy_document" "guardduty_logs" {
  statement {
    sid    = "EnforceSSL"
    effect = "Deny"
    actions = [
      "s3:*",
    ]
    resources = [
      aws_s3_bucket.guardduty_logs.arn,
      "${aws_s3_bucket.guardduty_logs.arn}/*",
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values = [
        "false",
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
    sid    = "GuardDutyBucketPermissionsCheck"
    effect = "Allow"
    actions = [
      "s3:GetBucketAcl",
      "s3:GetBucketLocation",
    ]
    resources = [
      aws_s3_bucket.guardduty_logs.arn,
    ]

    principals {
      type = "Service"
      identifiers = [
        "guardduty.amazonaws.com",
      ]
    }
  }

  statement {
    sid    = "GuardDutyBucketExistenceCheck"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
    ]
    resources = [
      aws_s3_bucket.guardduty_logs.arn,
    ]

    principals {
      type = "Service"
      identifiers = [
        "guardduty.amazonaws.com",
      ]
    }
  }

  statement {
    sid    = "GuardDutyBucketDelivery"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
    ]
    resources = [
      "${aws_s3_bucket.guardduty_logs.arn}/*",
    ]

    principals {
      type = "Service"
      identifiers = [
        "guardduty.amazonaws.com",
      ]
    }
  }
}


# ===============================================================================
# Amazon S3 Bucket for Secure Information
# ===============================================================================
resource "aws_s3_bucket" "secure_info" {
  bucket        = "${local.project}-${local.env}-${local.account_id}-s3-secure-info-bucket"
  force_destroy = true

  tags = {
    Name = "${local.project}-${local.env}-${local.account_id}-s3-secure-info-bucket"
  }
}

resource "aws_s3_bucket_ownership_controls" "secure_info" {
  bucket = aws_s3_bucket.secure_info.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "secure_info" {
  bucket = aws_s3_bucket.secure_info.id
  acl    = "private"

  depends_on = [
    aws_s3_bucket_ownership_controls.secure_info,
  ]
}

resource "aws_s3_bucket_public_access_block" "secure_info" {
  bucket = aws_s3_bucket.secure_info.id

  block_public_policy     = true
  block_public_acls       = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "secure_info" {
  bucket = aws_s3_bucket.secure_info.bucket

  rule {
    blocked_encryption_types = [
      "SSE-C"
    ]
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = false
  }
}

resource "aws_s3_bucket_versioning" "secure_info" {
  bucket = aws_s3_bucket.secure_info.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "secure_info" {
  bucket = aws_s3_bucket.secure_info.id

  target_bucket = aws_s3_bucket.s3_logs.id
  target_prefix = "secure-info/"

}

resource "aws_s3_bucket_lifecycle_configuration" "secure_info" {
  bucket = aws_s3_bucket.secure_info.id

  rule {
    id     = "transition-and-delete-object"
    status = "Enabled"

    filter {
      object_size_greater_than = 0
    }

    transition {
      days          = local.transition_days
      storage_class = "GLACIER"
    }

    expiration {
      days = local.expire_days
    }

    noncurrent_version_transition {
      noncurrent_days = local.transition_days
      storage_class   = "GLACIER"
    }

    noncurrent_version_expiration {
      noncurrent_days = local.expire_days
    }
  }

  depends_on = [
    aws_s3_bucket_versioning.secure_info,
  ]
}

resource "aws_s3_bucket_policy" "secure_info" {
  bucket = aws_s3_bucket.secure_info.id
  policy = data.aws_iam_policy_document.secure_info.json
}

data "aws_iam_policy_document" "secure_info" {
  statement {
    sid    = "EnforceSSL"
    effect = "Deny"
    actions = [
      "s3:*",
    ]
    resources = [
      aws_s3_bucket.secure_info.arn,
      "${aws_s3_bucket.secure_info.arn}/*",
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values = [
        "false",
      ]
    }

    principals {
      type = "AWS"
      identifiers = [
        "*",
      ]
    }
  }
}


# ===============================================================================
# Amazon S3 Bucket for Logging
# ===============================================================================
resource "aws_s3_bucket" "s3_logs" {
  bucket = "${local.project}-${local.env}-${local.account_id}-s3-logs-bucket"

  tags = {
    Name = "${local.project}-${local.env}-${local.account_id}-s3-logs-bucket"
  }
}

resource "aws_s3_bucket_ownership_controls" "s3_logs" {
  bucket = aws_s3_bucket.s3_logs.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "s3_logs" {
  bucket = aws_s3_bucket.s3_logs.id
  acl    = "log-delivery-write"

  depends_on = [
    aws_s3_bucket_ownership_controls.s3_logs,
  ]
}

resource "aws_s3_bucket_public_access_block" "s3_logs" {
  bucket = aws_s3_bucket.s3_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_logs" {
  bucket = aws_s3_bucket.s3_logs.bucket

  rule {
    blocked_encryption_types = [
      "SSE-C"
    ]
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = false
  }
}

resource "aws_s3_bucket_versioning" "s3_logs" {
  bucket = aws_s3_bucket.s3_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "s3_logs" {
  bucket = aws_s3_bucket.s3_logs.id

  rule {
    id     = "transition-and-delete-object"
    status = "Enabled"

    filter {
      object_size_greater_than = 0
    }

    transition {
      days          = local.transition_days
      storage_class = "GLACIER"
    }

    expiration {
      days = local.expire_days
    }

    noncurrent_version_transition {
      noncurrent_days = local.transition_days
      storage_class   = "GLACIER"
    }

    noncurrent_version_expiration {
      noncurrent_days = local.expire_days
    }
  }

  depends_on = [
    aws_s3_bucket_versioning.s3_logs,
  ]
}

resource "aws_s3_bucket_policy" "s3_logs" {
  bucket = aws_s3_bucket.s3_logs.id
  policy = data.aws_iam_policy_document.s3_logs.json
}

data "aws_iam_policy_document" "s3_logs" {
  statement {
    sid    = "EnforceSSL"
    effect = "Deny"
    actions = [
      "s3:*",
    ]
    resources = [
      aws_s3_bucket.s3_logs.arn,
      "${aws_s3_bucket.s3_logs.arn}/*",
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values = [
        "false",
      ]
    }

    principals {
      type = "AWS"
      identifiers = [
        "*",
      ]
    }
  }
}
