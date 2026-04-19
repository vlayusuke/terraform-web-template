data "aws_elb_service_account" "alb_logs" {}


# ===============================================================================
# Amazon S3 Bucket for Assets
# ===============================================================================
resource "aws_s3_bucket" "assets" {
  bucket = "${local.project}-${local.env}-s3-assets-bucket"

  tags = {
    Name = "${local.project}-${local.env}-s3-assets-bucket"
  }
}

resource "aws_s3_bucket_ownership_controls" "assets" {
  bucket = aws_s3_bucket.assets.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "assets" {
  bucket = aws_s3_bucket.assets.id
  acl    = "private"

  depends_on = [
    aws_s3_bucket_ownership_controls.assets,
  ]
}

resource "aws_s3_bucket_public_access_block" "assets" {
  bucket = aws_s3_bucket.assets.id

  block_public_policy     = true
  block_public_acls       = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "assets" {
  bucket = aws_s3_bucket.assets.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = false
  }
}

resource "aws_s3_bucket_versioning" "assets" {
  bucket = aws_s3_bucket.assets.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "assets" {
  bucket = aws_s3_bucket.assets.id

  target_bucket = aws_s3_bucket.s3_logs.id
  target_prefix = "assets/"
}

resource "aws_s3_bucket_lifecycle_configuration" "assets" {
  bucket = aws_s3_bucket.assets.id

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
    aws_s3_bucket_versioning.assets,
  ]
}

resource "aws_s3_bucket_cors_configuration" "assets" {
  bucket = aws_s3_bucket.assets.id

  cors_rule {
    allowed_headers = [
      "*",
    ]
    allowed_methods = [
      "PUT",
      "POST",
      "GET",
    ]
    allowed_origins = [
      "https://${local.domain}",
    ]
    max_age_seconds = 3600
  }
}

resource "aws_s3_bucket_policy" "assets_oac" {
  bucket = aws_s3_bucket.assets.id
  policy = data.aws_iam_policy_document.assets_oac.json
}

data "aws_iam_policy_document" "assets_oac" {
  statement {
    sid    = "EnforceSSL"
    effect = "Deny"
    actions = [
      "s3:*",
    ]
    resources = [
      aws_s3_bucket.assets.arn,
      "${aws_s3_bucket.assets.arn}/*",
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
    sid    = "S3List"
    effect = "Allow"

    principals {
      type = "Service"
      identifiers = [
        "cloudfront.amazonaws.com",
      ]
    }

    actions = [
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.assets.arn,
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values = [
        aws_cloudfront_distribution.main.arn,
      ]
    }
  }

  statement {
    sid    = "S3Get"
    effect = "Allow"

    principals {
      type = "Service"
      identifiers = [
        "cloudfront.amazonaws.com",
      ]
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${aws_s3_bucket.assets.arn}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values = [
        aws_cloudfront_distribution.main.arn,
      ]
    }
  }
}


# ===============================================================================
# Amazon S3 Bucket for Uploads
# ===============================================================================
resource "aws_s3_bucket" "uploads" {
  bucket = "${local.project}-${local.env}-s3-uploads-bucket"

  tags = {
    Name = "${local.project}-${local.env}-s3-uploads-bucket"
  }
}

resource "aws_s3_bucket_ownership_controls" "uploads" {
  bucket = aws_s3_bucket.uploads.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "uploads" {
  bucket = aws_s3_bucket.uploads.id
  acl    = "private"

  depends_on = [
    aws_s3_bucket_ownership_controls.uploads,
  ]
}

resource "aws_s3_bucket_public_access_block" "uploads" {
  bucket = aws_s3_bucket.uploads.id

  block_public_policy     = true
  block_public_acls       = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "uploads" {
  bucket = aws_s3_bucket.uploads.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = false
  }
}

resource "aws_s3_bucket_versioning" "uploads" {
  bucket = aws_s3_bucket.uploads.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "uploads" {
  bucket = aws_s3_bucket.uploads.id

  target_bucket = aws_s3_bucket.s3_logs.id
  target_prefix = "uploads/"
}

resource "aws_s3_bucket_lifecycle_configuration" "uploads" {
  bucket = aws_s3_bucket.uploads.id

  rule {
    id     = "transition-object"
    status = "Enabled"

    filter {
      object_size_greater_than = 0
    }

    transition {
      days          = local.expire_days
      storage_class = "GLACIER"
    }

    noncurrent_version_transition {
      noncurrent_days = local.expire_days
      storage_class   = "GLACIER"
    }
  }

  depends_on = [
    aws_s3_bucket_versioning.uploads,
  ]
}

resource "aws_s3_bucket_cors_configuration" "uploads" {
  bucket = aws_s3_bucket.uploads.id

  cors_rule {
    allowed_headers = [
      "*",
    ]
    allowed_methods = [
      "PUT",
      "POST",
      "GET",
    ]
    allowed_origins = [
      "https://${local.domain}",
    ]
    max_age_seconds = 3600
  }
}

resource "aws_s3_bucket_policy" "uploads_oac" {
  bucket = aws_s3_bucket.uploads.id
  policy = data.aws_iam_policy_document.uploads_oac.json
}

data "aws_iam_policy_document" "uploads_oac" {
  statement {
    sid    = "EnforceSSL"
    effect = "Deny"
    actions = [
      "s3:*",
    ]
    resources = [
      aws_s3_bucket.uploads.arn,
      "${aws_s3_bucket.uploads.arn}/*",
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
    sid    = "S3List"
    effect = "Allow"

    principals {
      type = "Service"
      identifiers = [
        "cloudfront.amazonaws.com",
      ]
    }

    actions = [
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.uploads.arn,
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values = [
        aws_cloudfront_distribution.main.arn,
      ]
    }
  }

  statement {
    sid    = "S3GetAndPut"
    effect = "Allow"

    principals {
      type = "Service"
      identifiers = [
        "cloudfront.amazonaws.com",
      ]
    }

    actions = [
      "s3:GetObject",
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.uploads.arn}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values = [
        aws_cloudfront_distribution.main.arn
      ]
    }
  }
}


# ===============================================================================
# Amazon S3 Bucket for ALB logs
# ===============================================================================
resource "aws_s3_bucket" "alb_logs" {
  bucket = "${local.project}-${local.env}-s3-alb-logs-bucket"

  tags = {
    Name = "${local.project}-${local.env}-s3-alb-logs-bucket"
  }
}

resource "aws_s3_bucket_ownership_controls" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id
  acl    = "private"

  depends_on = [
    aws_s3_bucket_ownership_controls.alb_logs,
  ]
}

resource "aws_s3_bucket_public_access_block" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id
  policy = data.aws_iam_policy_document.alb_logs.json
}

resource "aws_s3_bucket_server_side_encryption_configuration" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = false
  }
}

resource "aws_s3_bucket_versioning" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id

  target_bucket = aws_s3_bucket.s3_logs.id
  target_prefix = "alb-logs/"
}

resource "aws_s3_bucket_lifecycle_configuration" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id

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
    aws_s3_bucket_versioning.alb_logs,
  ]
}

data "aws_iam_policy_document" "alb_logs" {
  statement {
    sid    = "EnforceSSL"
    effect = "Deny"
    actions = [
      "s3:*",
    ]
    resources = [
      aws_s3_bucket.alb_logs.arn,
      "${aws_s3_bucket.alb_logs.arn}/*",
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
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_elb_service_account.alb_logs.id}:root",
      ]
    }
    effect = "Allow"
    actions = [
      "s3:PutObject",
    ]
    resources = [
      "${aws_s3_bucket.alb_logs.arn}/*",
    ]
  }

  statement {
    principals {
      type = "Service"
      identifiers = [
        "delivery.logs.amazonaws.com",
      ]
    }
    effect = "Allow"
    actions = [
      "s3:PutObject",
    ]
    resources = [
      "${aws_s3_bucket.alb_logs.arn}/*",
    ]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values = [
        "bucket-owner-full-control",
      ]
    }
  }
}


# ===============================================================================
# Amazon S3 Bucket for VPC flow log
# ===============================================================================
resource "aws_s3_bucket" "vpc_flow_log" {
  bucket = "${local.project}-${local.env}-s3-vpc-flow-log-bucket"

  tags = {
    Name = "${local.project}-${local.env}-s3-vpc-flow-log-bucket"
  }
}

resource "aws_s3_bucket_ownership_controls" "vpc_flow_log" {
  bucket = aws_s3_bucket.vpc_flow_log.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "vpc_flow_log" {
  bucket = aws_s3_bucket.vpc_flow_log.id
  acl    = "private"

  depends_on = [
    aws_s3_bucket_ownership_controls.vpc_flow_log,
  ]
}

resource "aws_s3_bucket_public_access_block" "vpc_flow_log" {
  bucket = aws_s3_bucket.vpc_flow_log.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "vpc_flow_log" {
  bucket = aws_s3_bucket.vpc_flow_log.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = false
  }
}

resource "aws_s3_bucket_versioning" "vpc_flow_log" {
  bucket = aws_s3_bucket.vpc_flow_log.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "vpc_flow_log" {
  bucket = aws_s3_bucket.vpc_flow_log.id

  target_bucket = aws_s3_bucket.s3_logs.id
  target_prefix = "vpc-flow-log/"
}

resource "aws_s3_bucket_lifecycle_configuration" "vpc_flow_log" {
  bucket = aws_s3_bucket.vpc_flow_log.id

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
    aws_s3_bucket_versioning.vpc_flow_log,
  ]
}

resource "aws_s3_bucket_policy" "vpc_flow_log" {
  bucket = aws_s3_bucket.vpc_flow_log.id
  policy = data.aws_iam_policy_document.vpc_flow_log.json
}

data "aws_iam_policy_document" "vpc_flow_log" {
  statement {
    sid    = "EnforceSSL"
    effect = "Deny"
    actions = [
      "s3:*",
    ]
    resources = [
      aws_s3_bucket.vpc_flow_log.arn,
      "${aws_s3_bucket.vpc_flow_log.arn}/*",
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
# Amazon S3 Bucket for Amazon ECS logs
# ===============================================================================
resource "aws_s3_bucket" "ecs_logs" {
  bucket = "${local.project}-${local.env}-s3-ecs-logs-bucket"

  tags = {
    Name = "${local.project}-${local.env}-s3-ecs-logs-bucket"
  }
}

resource "aws_s3_object" "prefix_app_app" {
  bucket = aws_s3_bucket.ecs_logs.bucket
  key    = "app-app/"
  acl    = "private"

  tags = {
    Name = "${local.project}-${local.env}-s3-prefix-app-app"
  }
}

resource "aws_s3_object" "prefix_app_nginx" {
  bucket = aws_s3_bucket.ecs_logs.bucket
  key    = "app-nginx/"
  acl    = "private"

  tags = {
    Name = "${local.project}-${local.env}-s3-prefix-app-nginx"
  }
}

resource "aws_s3_object" "prefix_cron" {
  bucket = aws_s3_bucket.ecs_logs.bucket
  key    = "cron/"
  acl    = "private"

  tags = {
    Name = "${local.project}-${local.env}-s3-prefix-cron"
  }
}

resource "aws_s3_object" "prefix_queue" {
  bucket = aws_s3_bucket.ecs_logs.bucket
  key    = "queue/"
  acl    = "private"

  tags = {
    Name = "${local.project}-${local.env}-s3-prefix-queue"
  }
}

resource "aws_s3_object" "prefix_migrate" {
  bucket = aws_s3_bucket.ecs_logs.bucket
  key    = "migrate/"
  acl    = "private"

  tags = {
    Name = "${local.project}-${local.env}-s3-prefix-migrate"
  }
}

resource "aws_s3_object" "prefix_firelens" {
  bucket = aws_s3_bucket.ecs_logs.bucket
  key    = "firelens/"
  acl    = "private"

  tags = {
    Name = "${local.project}-${local.env}-s3-prefix-firelens"
  }
}

resource "aws_s3_bucket_ownership_controls" "ecs_logs" {
  bucket = aws_s3_bucket.ecs_logs.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "ecs_logs" {
  bucket = aws_s3_bucket.ecs_logs.id
  acl    = "private"

  depends_on = [
    aws_s3_bucket_ownership_controls.ecs_logs,
  ]
}

resource "aws_s3_bucket_public_access_block" "ecs_logs" {
  bucket = aws_s3_bucket.ecs_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "ecs_logs" {
  bucket = aws_s3_bucket.ecs_logs.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = false
  }
}

resource "aws_s3_bucket_versioning" "ecs_logs" {
  bucket = aws_s3_bucket.ecs_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "ecs_logs" {
  bucket = aws_s3_bucket.ecs_logs.id

  target_bucket = aws_s3_bucket.s3_logs.id
  target_prefix = "ecs-logs/"
}

resource "aws_s3_bucket_lifecycle_configuration" "ecs_logs" {
  bucket = aws_s3_bucket.ecs_logs.id

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
    aws_s3_bucket_versioning.ecs_logs,
  ]
}

resource "aws_s3_bucket_policy" "ecs_logs" {
  bucket = aws_s3_bucket.ecs_logs.id
  policy = data.aws_iam_policy_document.ecs_logs.json
}

data "aws_iam_policy_document" "ecs_logs" {
  statement {
    sid    = "EnforceSSL"
    effect = "Deny"
    actions = [
      "s3:*",
    ]
    resources = [
      aws_s3_bucket.ecs_logs.arn,
      "${aws_s3_bucket.ecs_logs.arn}/*",
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
# Amazon S3 Bucket for AWS Lambda logs
# ===============================================================================
resource "aws_s3_bucket" "lambda_logs" {
  bucket = "${local.project}-${local.env}-s3-lambda-logs-bucket"

  tags = {
    Name = "${local.project}-${local.env}-s3-lambda-logs-bucket"
  }
}

resource "aws_s3_object" "prefix_lambda" {
  for_each = local.lambda_functions
  bucket   = aws_s3_bucket.lambda_logs.bucket
  key      = "${each.key}/"
  acl      = "private"

  tags = {
    Name = "${local.project}-${local.env}-s3-prefix-lambda-${each.key}"
  }
}

resource "aws_s3_bucket_ownership_controls" "lambda_logs" {
  bucket = aws_s3_bucket.lambda_logs.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "lambda_logs" {
  bucket = aws_s3_bucket.lambda_logs.id
  acl    = "private"

  depends_on = [
    aws_s3_bucket_ownership_controls.lambda_logs,
  ]
}

resource "aws_s3_bucket_public_access_block" "lambda_logs" {
  bucket = aws_s3_bucket.lambda_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "lambda_logs" {
  bucket = aws_s3_bucket.lambda_logs.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = false
  }
}

resource "aws_s3_bucket_versioning" "lambda_logs" {
  bucket = aws_s3_bucket.lambda_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "lambda_logs" {
  bucket = aws_s3_bucket.lambda_logs.id

  target_bucket = aws_s3_bucket.s3_logs.id
  target_prefix = "lambda-logs/"
}

resource "aws_s3_bucket_lifecycle_configuration" "lambda_logs" {
  bucket = aws_s3_bucket.lambda_logs.id

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
    aws_s3_bucket_versioning.lambda_logs,
  ]
}

resource "aws_s3_bucket_policy" "lambda_logs" {
  bucket = aws_s3_bucket.lambda_logs.id
  policy = data.aws_iam_policy_document.lambda_logs.json
}

data "aws_iam_policy_document" "lambda_logs" {
  statement {
    sid    = "EnforceSSL"
    effect = "Deny"
    actions = [
      "s3:*",
    ]
    resources = [
      aws_s3_bucket.lambda_logs.arn,
      "${aws_s3_bucket.lambda_logs.arn}/*",
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
# Amazon S3 Bucket for Amazon Aurora logs
# ===============================================================================
resource "aws_s3_bucket" "aurora_logs" {
  bucket = "${local.project}-${local.env}-s3-aurora-logs-bucket"

  tags = {
    Name = "${local.project}-${local.env}-s3-aurora-logs-bucket"
  }
}

resource "aws_s3_object" "prefix_audit" {
  bucket = aws_s3_bucket.aurora_logs.bucket
  key    = "audit/"
  acl    = "private"

  tags = {
    Name = "${local.project}-${local.env}-s3-prefix-audit"
  }
}

resource "aws_s3_object" "prefix_error" {
  bucket = aws_s3_bucket.aurora_logs.bucket
  key    = "error/"
  acl    = "private"

  tags = {
    Name = "${local.project}-${local.env}-s3-prefix-error"
  }
}

resource "aws_s3_object" "prefix_general" {
  bucket = aws_s3_bucket.aurora_logs.bucket
  key    = "general/"
  acl    = "private"

  tags = {
    Name = "${local.project}-${local.env}-s3-prefix-general"
  }
}

resource "aws_s3_object" "prefix_slowquery" {
  bucket = aws_s3_bucket.aurora_logs.bucket
  key    = "slowquery/"
  acl    = "private"

  tags = {
    Name = "${local.project}-${local.env}-s3-prefix-slowquery"
  }
}

resource "aws_s3_object" "prefix_iam_db_auth_error" {
  bucket = aws_s3_bucket.aurora_logs.bucket
  key    = "iam-db-auth-error/"
  acl    = "private"

  tags = {
    Name = "${local.project}-${local.env}-s3-prefix-iam-db-auth-error"
  }
}

resource "aws_s3_bucket_ownership_controls" "aurora_logs" {
  bucket = aws_s3_bucket.aurora_logs.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "aurora_logs" {
  bucket = aws_s3_bucket.aurora_logs.id
  acl    = "private"

  depends_on = [
    aws_s3_bucket_ownership_controls.aurora_logs,
  ]
}

resource "aws_s3_bucket_public_access_block" "aurora_logs" {
  bucket = aws_s3_bucket.aurora_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "aurora_logs" {
  bucket = aws_s3_bucket.aurora_logs.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = false
  }
}

resource "aws_s3_bucket_versioning" "aurora_logs" {
  bucket = aws_s3_bucket.aurora_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "aurora_logs" {
  bucket = aws_s3_bucket.aurora_logs.id

  target_bucket = aws_s3_bucket.s3_logs.id
  target_prefix = "aurora-logs/"
}

resource "aws_s3_bucket_lifecycle_configuration" "aurora_logs" {
  bucket = aws_s3_bucket.aurora_logs.id

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
    aws_s3_bucket_versioning.aurora_logs,
  ]
}

resource "aws_s3_bucket_policy" "aurora_logs" {
  bucket = aws_s3_bucket.aurora_logs.id
  policy = data.aws_iam_policy_document.aurora_logs.json
}

data "aws_iam_policy_document" "aurora_logs" {
  statement {
    sid    = "EnforceSSL"
    effect = "Deny"
    actions = [
      "s3:*",
    ]
    resources = [
      aws_s3_bucket.aurora_logs.arn,
      "${aws_s3_bucket.aurora_logs.arn}/*",
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
# Amazon S3 Bucket for Amazon SES logs
# ===============================================================================
resource "aws_s3_bucket" "ses_logs" {
  bucket = "${local.project}-${local.env}-s3-ses-logs-bucket"

  tags = {
    Name = "${local.project}-${local.env}-s3-ses-logs-bucket"
  }
}

resource "aws_s3_bucket_ownership_controls" "ses_logs" {
  bucket = aws_s3_bucket.ses_logs.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "ses_logs" {
  bucket = aws_s3_bucket.ses_logs.id
  acl    = "private"

  depends_on = [
    aws_s3_bucket_ownership_controls.ses_logs,
  ]
}

resource "aws_s3_bucket_public_access_block" "ses_logs" {
  bucket = aws_s3_bucket.ses_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "ses_logs" {
  bucket = aws_s3_bucket.ses_logs.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = false
  }
}

resource "aws_s3_bucket_versioning" "ses_logs" {
  bucket = aws_s3_bucket.ses_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "ses_logs" {
  bucket = aws_s3_bucket.ses_logs.id

  target_bucket = aws_s3_bucket.s3_logs.id
  target_prefix = "ses-logs/"
}

resource "aws_s3_bucket_lifecycle_configuration" "ses_logs" {
  bucket = aws_s3_bucket.ses_logs.id

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
    aws_s3_bucket_versioning.ses_logs,
  ]
}

resource "aws_s3_bucket_policy" "ses_logs" {
  bucket = aws_s3_bucket.ses_logs.id
  policy = data.aws_iam_policy_document.ses_logs.json
}

data "aws_iam_policy_document" "ses_logs" {
  statement {
    sid    = "EnforceSSL"
    effect = "Deny"
    actions = [
      "s3:*",
    ]
    resources = [
      aws_s3_bucket.ses_logs.arn,
      "${aws_s3_bucket.ses_logs.arn}/*",
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
# Amazon S3 Bucket for Amazon SES event logs
# ===============================================================================
resource "aws_s3_bucket" "ses_event_logs" {
  bucket = "${local.project}-${local.env}-s3-ses-event-logs-bucket"

  tags = {
    Name = "${local.project}-${local.env}-s3-ses-event-logs-bucket"
  }
}

resource "aws_s3_bucket_ownership_controls" "ses_event_logs" {
  bucket = aws_s3_bucket.ses_event_logs.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "ses_event_logs" {
  bucket = aws_s3_bucket.ses_event_logs.id
  acl    = "private"

  depends_on = [
    aws_s3_bucket_ownership_controls.ses_event_logs,
  ]
}

resource "aws_s3_bucket_public_access_block" "ses_event_logs" {
  bucket = aws_s3_bucket.ses_event_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "ses_event_logs" {
  bucket = aws_s3_bucket.ses_event_logs.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = false
  }
}

resource "aws_s3_bucket_versioning" "ses_event_logs" {
  bucket = aws_s3_bucket.ses_event_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "ses_event_logs" {
  bucket = aws_s3_bucket.ses_event_logs.id

  target_bucket = aws_s3_bucket.s3_logs.id
  target_prefix = "ses-event-logs/"
}

resource "aws_s3_bucket_lifecycle_configuration" "ses_event_logs" {
  bucket = aws_s3_bucket.ses_event_logs.id

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
    aws_s3_bucket_versioning.ses_event_logs,
  ]
}

resource "aws_s3_bucket_policy" "ses_event_logs" {
  bucket = aws_s3_bucket.ses_event_logs.id
  policy = data.aws_iam_policy_document.ses_event_logs.json
}

data "aws_iam_policy_document" "ses_event_logs" {
  statement {
    sid    = "EnforceSSL"
    effect = "Deny"
    actions = [
      "s3:*",
    ]
    resources = [
      aws_s3_bucket.ses_event_logs.arn,
      "${aws_s3_bucket.ses_event_logs.arn}/*",
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
# Amazon S3 Bucket for Amazon SNS logs
# ===============================================================================
resource "aws_s3_bucket" "sns_logs" {
  bucket = "${local.project}-${local.env}-s3-sns-logs-bucket"

  tags = {
    Name = "${local.project}-${local.env}-s3-sns-logs-bucket"
  }
}

resource "aws_s3_bucket_ownership_controls" "sns_logs" {
  bucket = aws_s3_bucket.sns_logs.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "sns_logs" {
  bucket = aws_s3_bucket.sns_logs.id
  acl    = "private"

  depends_on = [
    aws_s3_bucket_ownership_controls.sns_logs,
  ]
}

resource "aws_s3_bucket_public_access_block" "sns_logs" {
  bucket = aws_s3_bucket.sns_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sns_logs" {
  bucket = aws_s3_bucket.sns_logs.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = false
  }
}

resource "aws_s3_bucket_versioning" "sns_logs" {
  bucket = aws_s3_bucket.sns_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "sns_logs" {
  bucket = aws_s3_bucket.sns_logs.id

  target_bucket = aws_s3_bucket.s3_logs.id
  target_prefix = "sns-logs/"
}

resource "aws_s3_bucket_lifecycle_configuration" "sns_logs" {
  bucket = aws_s3_bucket.sns_logs.id

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
    aws_s3_bucket_versioning.sns_logs,
  ]
}

resource "aws_s3_bucket_policy" "sns_logs" {
  bucket = aws_s3_bucket.sns_logs.id
  policy = data.aws_iam_policy_document.sns_logs.json
}

data "aws_iam_policy_document" "sns_logs" {
  statement {
    sid    = "EnforceSSL"
    effect = "Deny"
    actions = [
      "s3:*",
    ]
    resources = [
      aws_s3_bucket.sns_logs.arn,
      "${aws_s3_bucket.sns_logs.arn}/*",
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
# Amazon S3 Bucket for Amazon SNS event logs
# ===============================================================================
resource "aws_s3_bucket" "sns_event_logs" {
  bucket = "${local.project}-${local.env}-s3-sns-event-logs-bucket"

  tags = {
    Name = "${local.project}-${local.env}-s3-sns-event-logs-bucket"
  }
}

resource "aws_s3_bucket_ownership_controls" "sns_event_logs" {
  bucket = aws_s3_bucket.sns_event_logs.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "sns_event_logs" {
  bucket = aws_s3_bucket.sns_event_logs.id
  acl    = "private"

  depends_on = [
    aws_s3_bucket_ownership_controls.sns_event_logs,
  ]
}

resource "aws_s3_bucket_public_access_block" "sns_event_logs" {
  bucket                  = aws_s3_bucket.sns_event_logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sns_event_logs" {
  bucket = aws_s3_bucket.sns_event_logs.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = false
  }
}

resource "aws_s3_bucket_versioning" "sns_event_logs" {
  bucket = aws_s3_bucket.sns_event_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "sns_event_logs" {
  bucket        = aws_s3_bucket.sns_event_logs.id
  target_bucket = aws_s3_bucket.s3_logs.id
  target_prefix = "sns-event-logs/"
}

resource "aws_s3_bucket_lifecycle_configuration" "sns_event_logs" {
  bucket = aws_s3_bucket.sns_event_logs.id

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
    aws_s3_bucket_versioning.sns_event_logs,
  ]
}

resource "aws_s3_bucket_policy" "sns_event_logs" {
  bucket = aws_s3_bucket.sns_event_logs.id
  policy = data.aws_iam_policy_document.sns_event_logs.json
}

data "aws_iam_policy_document" "sns_event_logs" {
  statement {
    sid    = "EnforceSSL"
    effect = "Deny"
    actions = [
      "s3:*",
    ]
    resources = [
      aws_s3_bucket.sns_event_logs.arn,
      "${aws_s3_bucket.sns_event_logs.arn}/*",
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
# Amazon S3 Bucket for Amazon CloudFront logs
# ===============================================================================
resource "aws_s3_bucket" "cloudfront_logs" {
  bucket = "${local.project}-${local.env}-s3-cloudfront-logs-bucket"

  tags = {
    Name = "${local.project}-${local.env}-s3-cloudfront-logs-bucket"
  }
}

resource "aws_s3_bucket_ownership_controls" "cloudfront_logs" {
  bucket = aws_s3_bucket.cloudfront_logs.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "cloudfront_logs" {
  bucket = aws_s3_bucket.cloudfront_logs.id
  acl    = "private"

  depends_on = [
    aws_s3_bucket_ownership_controls.cloudfront_logs,
  ]
}

resource "aws_s3_bucket_public_access_block" "cloudfront_logs" {
  bucket = aws_s3_bucket.cloudfront_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudfront_logs" {
  bucket = aws_s3_bucket.cloudfront_logs.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = false
  }
}

resource "aws_s3_bucket_versioning" "cloudfront_logs" {
  bucket = aws_s3_bucket.cloudfront_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "cloudfront_logs" {
  bucket = aws_s3_bucket.cloudfront_logs.id

  target_bucket = aws_s3_bucket.s3_logs.id
  target_prefix = "cloudfront-logs/"
}

resource "aws_s3_bucket_lifecycle_configuration" "cloudfront_logs" {
  bucket = aws_s3_bucket.cloudfront_logs.id

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
    aws_s3_bucket_versioning.cloudfront_logs,
  ]
}

resource "aws_s3_bucket_policy" "cloudfront_logs" {
  bucket = aws_s3_bucket.cloudfront_logs.id
  policy = data.aws_iam_policy_document.cloudfront_logs.json
}

data "aws_iam_policy_document" "cloudfront_logs" {
  statement {
    sid    = "EnforceSSL"
    effect = "Deny"
    actions = [
      "s3:*",
    ]
    resources = [
      aws_s3_bucket.cloudfront_logs.arn,
      "${aws_s3_bucket.cloudfront_logs.arn}/*",
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
# Amazon S3 Bucket for AWS WAFv2 Logs
# ===============================================================================
resource "aws_s3_bucket" "waf_logs" {
  bucket = "aws-waf-logs-${local.project}-${local.env}-s3-waf-logs-bucket"

  tags = {
    Name = "${local.project}-${local.env}-s3-waf-logs-bucket"
  }
}

resource "aws_s3_bucket_ownership_controls" "waf_logs" {
  bucket = aws_s3_bucket.waf_logs.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "waf_logs" {
  bucket = aws_s3_bucket.waf_logs.id
  acl    = "log-delivery-write"

  depends_on = [
    aws_s3_bucket_ownership_controls.waf_logs,
  ]
}

resource "aws_s3_bucket_public_access_block" "waf_logs" {
  bucket = aws_s3_bucket.waf_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "waf_logs" {
  bucket = aws_s3_bucket.waf_logs.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = false
  }
}

resource "aws_s3_bucket_versioning" "waf_logs" {
  bucket = aws_s3_bucket.waf_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "waf_logs" {
  bucket = aws_s3_bucket.waf_logs.id

  target_bucket = aws_s3_bucket.s3_logs.id
  target_prefix = "waf-logs/"
}

resource "aws_s3_bucket_lifecycle_configuration" "waf_logs" {
  bucket = aws_s3_bucket.waf_logs.id

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
    aws_s3_bucket_versioning.waf_logs,
  ]
}

resource "aws_s3_bucket_policy" "waf_logs" {
  bucket = aws_s3_bucket.waf_logs.id
  policy = data.aws_iam_policy_document.waf_logs.json
}

data "aws_iam_policy_document" "waf_logs" {
  statement {
    sid    = "EnforceSSL"
    effect = "Deny"
    actions = [
      "s3:*",
    ]
    resources = [
      aws_s3_bucket.waf_logs.arn,
      "${aws_s3_bucket.waf_logs.arn}/*",
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


# ================================================================================
# Amazon S3 Bucket for Amazon EC2 Bastion
# ================================================================================
resource "aws_s3_bucket" "bastion" {
  bucket = "${local.project}-${local.env}-s3-bastion-bucket"

  tags = {
    Name = "${local.project}-${local.env}-s3-bastion-bucket"
  }
}

resource "aws_s3_object" "prefix_bastion_logs" {
  bucket = aws_s3_bucket.bastion.bucket
  key    = "bastion-logs/"
  acl    = "private"

  tags = {
    Name = "${local.project}-${local.env}-s3-prefix-bastion-logs"
  }
}

resource "aws_s3_bucket_ownership_controls" "bastion" {
  bucket = aws_s3_bucket.bastion.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "bastion" {
  bucket = aws_s3_bucket.bastion.id
  acl    = "private"

  depends_on = [
    aws_s3_bucket_ownership_controls.bastion,
  ]
}

resource "aws_s3_bucket_public_access_block" "bastion" {
  bucket = aws_s3_bucket.bastion.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bastion" {
  bucket = aws_s3_bucket.bastion.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = false
  }
}

resource "aws_s3_bucket_versioning" "bastion" {
  bucket = aws_s3_bucket.bastion.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "bastion" {
  bucket = aws_s3_bucket.bastion.id

  target_bucket = aws_s3_bucket.s3_logs.id
  target_prefix = "bastion/"
}

resource "aws_s3_bucket_lifecycle_configuration" "bastion" {
  bucket = aws_s3_bucket.bastion.id

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
    aws_s3_bucket_versioning.bastion,
  ]
}

resource "aws_s3_bucket_policy" "bastion" {
  bucket = aws_s3_bucket.bastion.id
  policy = data.aws_iam_policy_document.bastion_bucket_policy.json
}

data "aws_iam_policy_document" "bastion_bucket_policy" {
  statement {
    sid    = "EnforceSSL"
    effect = "Deny"
    actions = [
      "s3:*",
    ]
    resources = [
      aws_s3_bucket.bastion.arn,
      "${aws_s3_bucket.bastion.arn}/*",
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

resource "aws_s3_object" "bastion_sh" {
  bucket                 = aws_s3_bucket.bastion.id
  key                    = "bastion.sh"
  content                = local.bastion_ssh
  server_side_encryption = "AES256"

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_s3_object" "install_iam_ssh_sh" {
  bucket                 = aws_s3_bucket.bastion.id
  key                    = "install_iam_ssh.sh"
  content                = local.install_iam_ssh_sh
  server_side_encryption = "AES256"

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_s3_object" "aws_ec2_ssh_conf" {
  bucket                 = aws_s3_bucket.bastion.id
  key                    = "aws-ec2-ssh.conf"
  content                = local.aws_ec2_ssh_conf
  server_side_encryption = "AES256"

  lifecycle {
    prevent_destroy = false
  }
}

locals {
  bastion_ssh = templatefile(
    "files/startup_scripts/bastion.sh",
    {
      bastion_bucket = aws_s3_bucket.bastion.id
    }
  )

  install_iam_ssh_sh = templatefile(
    "files/iam_ssh/install_iam_ssh.sh",
    {
      bucket = aws_s3_bucket.bastion.id
    }
  )

  aws_ec2_ssh_conf = templatefile(
    "files/iam_ssh/aws-ec2-ssh.conf",
    {
      project = local.project
    }
  )
}


# ===============================================================================
# Amazon S3 Bucket for Amazon S3 Server Access Logs
# ===============================================================================
resource "aws_s3_bucket" "s3_server_access_logs" {
  bucket = "${local.project}-${local.env}-s3-server-access-logs-bucket"

  tags = {
    Name = "${local.project}-${local.env}-s3-server-access-logs-bucket"
  }
}

resource "aws_s3_bucket_ownership_controls" "s3_server_access_logs" {
  bucket = aws_s3_bucket.s3_server_access_logs.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "s3_server_access_logs" {
  bucket = aws_s3_bucket.s3_server_access_logs.id
  acl    = "log-delivery-write"

  depends_on = [
    aws_s3_bucket_ownership_controls.s3_server_access_logs,
  ]
}

resource "aws_s3_bucket_public_access_block" "s3_server_access_logs" {
  bucket = aws_s3_bucket.s3_server_access_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_server_access_logs" {
  bucket = aws_s3_bucket.s3_server_access_logs.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = false
  }
}

resource "aws_s3_bucket_versioning" "s3_server_access_logs" {
  bucket = aws_s3_bucket.s3_server_access_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "s3_server_access_logs" {
  bucket = aws_s3_bucket.s3_server_access_logs.id

  target_bucket = aws_s3_bucket.s3_logs.id
  target_prefix = "server-access-logs/"
}

resource "aws_s3_bucket_lifecycle_configuration" "s3_server_access_logs" {
  bucket = aws_s3_bucket.s3_server_access_logs.id

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
    aws_s3_bucket_versioning.s3_server_access_logs,
  ]
}

resource "aws_s3_bucket_policy" "s3_server_access_logs" {
  bucket = aws_s3_bucket.s3_server_access_logs.id
  policy = data.aws_iam_policy_document.s3_server_access_logs.json
}

data "aws_iam_policy_document" "s3_server_access_logs" {
  statement {
    sid    = "EnforceSSL"
    effect = "Deny"
    actions = [
      "s3:*",
    ]
    resources = [
      aws_s3_bucket.s3_server_access_logs.arn,
      "${aws_s3_bucket.s3_server_access_logs.arn}/*",
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


# ================================================================================
# Amazon S3 Bucket for Source Code Backup (Osaka)
# ================================================================================
resource "aws_s3_bucket" "source_backup_osaka" {
  bucket   = "${local.project}-${local.env}-s3-github-backup-osaka-bucket"
  provider = aws.osaka

  tags = {
    Name = "${local.project}-${local.env}-s3-github-backup-osaka-bucket"
  }
}

resource "aws_s3_bucket_ownership_controls" "source_backup_osaka" {
  bucket   = aws_s3_bucket.source_backup_osaka.id
  provider = aws.osaka

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "source_backup_osaka" {
  bucket   = aws_s3_bucket.source_backup_osaka.id
  acl      = "private"
  provider = aws.osaka

  depends_on = [
    aws_s3_bucket_ownership_controls.source_backup_osaka,
  ]
}

resource "aws_s3_bucket_public_access_block" "source_backup_osaka" {
  bucket   = aws_s3_bucket.source_backup_osaka.id
  provider = aws.osaka

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "source_backup_osaka" {
  bucket   = aws_s3_bucket.source_backup_osaka.bucket
  provider = aws.osaka

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = false
  }
}

resource "aws_s3_bucket_versioning" "source_backup_osaka" {
  bucket   = aws_s3_bucket.source_backup_osaka.id
  provider = aws.osaka

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_policy" "source_backup_osaka" {
  bucket   = aws_s3_bucket.source_backup_osaka.id
  policy   = data.aws_iam_policy_document.source_backup_osaka.json
  provider = aws.osaka
}

data "aws_iam_policy_document" "source_backup_osaka" {
  provider = aws.osaka

  statement {
    sid    = "EnforceSSL"
    effect = "Deny"
    actions = [
      "s3:*",
    ]
    resources = [
      aws_s3_bucket.source_backup_osaka.arn,
      "${aws_s3_bucket.source_backup_osaka.arn}/*",
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
# Amazon S3 Bucket for Amazon S3 Logging
# ===============================================================================
resource "aws_s3_bucket" "s3_logs" {
  bucket = "${local.project}-${local.env}-s3-logs-bucket"

  tags = {
    Name = "${local.project}-${local.env}-s3-logs-bucket"
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
