# ===============================================================================
# Amazon Data Firehose Stream (Amazon Aurora logs)
# ===============================================================================
resource "aws_kinesis_firehose_delivery_stream" "aurora_logs_audit" {
  name        = "${local.project}-${local.env}-adf-aur-logs-audit-to-s3"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn           = aws_iam_role.amazon_data_firehose.arn
    bucket_arn         = aws_s3_bucket.aurora_logs.arn
    buffering_size     = 64
    buffering_interval = 300
    prefix             = "${local.env}/audit-logs/"
    compression_format = "GZIP"
    file_extension     = ".json"
    custom_time_zone   = "Asia/Tokyo"
  }

  server_side_encryption {
    enabled  = true
    key_type = "AWS_OWNED_CMK"
  }

  lifecycle {
    prevent_destroy = false
  }

  depends_on = [
    aws_iam_role_policy_attachment.amazon_data_firehose,
  ]

  tags = {
    Name = "${local.project}-${local.env}-adf-aur-logs-audit-to-s3"
  }
}

resource "aws_kinesis_firehose_delivery_stream" "aurora_logs_error" {
  name        = "${local.project}-${local.env}-adf-aur-logs-error-to-s3"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn           = aws_iam_role.amazon_data_firehose.arn
    bucket_arn         = aws_s3_bucket.aurora_logs.arn
    buffering_size     = 64
    buffering_interval = 300
    prefix             = "${local.env}/error-logs/"
    file_extension     = ".json"
    custom_time_zone   = "Asia/Tokyo"
    compression_format = "GZIP"
  }

  server_side_encryption {
    enabled  = true
    key_type = "AWS_OWNED_CMK"
  }

  lifecycle {
    prevent_destroy = false
  }

  depends_on = [
    aws_iam_role_policy_attachment.amazon_data_firehose,
  ]

  tags = {
    Name = "${local.project}-${local.env}-adf-aur-logs-error-to-s3"
  }
}

resource "aws_kinesis_firehose_delivery_stream" "aurora_logs_general" {
  name        = "${local.project}-${local.env}-adf-aur-logs-general-to-s3"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn           = aws_iam_role.amazon_data_firehose.arn
    bucket_arn         = aws_s3_bucket.aurora_logs.arn
    buffering_size     = 64
    buffering_interval = 300
    prefix             = "${local.env}/general-logs/"
    file_extension     = ".json"
    custom_time_zone   = "Asia/Tokyo"
    compression_format = "GZIP"
  }

  server_side_encryption {
    enabled  = true
    key_type = "AWS_OWNED_CMK"
  }

  lifecycle {
    prevent_destroy = false
  }

  depends_on = [
    aws_iam_role_policy_attachment.amazon_data_firehose,
  ]

  tags = {
    Name = "${local.project}-${local.env}-adf-aur-logs-general-to-s3"
  }
}

resource "aws_kinesis_firehose_delivery_stream" "aurora_logs_slowquery" {
  name        = "${local.project}-${local.env}-adf-aur-logs-slowquery-to-s3"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn           = aws_iam_role.amazon_data_firehose.arn
    bucket_arn         = aws_s3_bucket.aurora_logs.arn
    buffering_size     = 64
    buffering_interval = 300
    prefix             = "${local.env}/slowquery-logs/"
    file_extension     = ".json"
    custom_time_zone   = "Asia/Tokyo"
    compression_format = "GZIP"
  }

  server_side_encryption {
    enabled  = true
    key_type = "AWS_OWNED_CMK"
  }

  lifecycle {
    prevent_destroy = false
  }

  depends_on = [
    aws_iam_role_policy_attachment.amazon_data_firehose,
    aws_s3_bucket.aurora_logs,
  ]

  tags = {
    Name = "${local.project}-${local.env}-adf-aur-logs-slowquery-to-s3"
  }
}

resource "aws_kinesis_firehose_delivery_stream" "aurora_logs_iam_db_auth_error" {
  name        = "${local.project}-${local.env}-adf-aur-logs-auth-error-to-s3"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn           = aws_iam_role.amazon_data_firehose.arn
    bucket_arn         = aws_s3_bucket.aurora_logs.arn
    buffering_size     = 64
    buffering_interval = 300
    prefix             = "${local.env}/auth-error-logs/"
    file_extension     = ".json"
    custom_time_zone   = "Asia/Tokyo"
    compression_format = "GZIP"
  }

  server_side_encryption {
    enabled  = true
    key_type = "AWS_OWNED_CMK"
  }

  lifecycle {
    prevent_destroy = false
  }

  depends_on = [
    aws_iam_role_policy_attachment.amazon_data_firehose,
    aws_s3_bucket.aurora_logs,
  ]

  tags = {
    Name = "${local.project}-${local.env}-adf-aur-logs-auth-error-to-s3"
  }
}


# ===============================================================================
# Amazon Data Firehose Stream (Amazon ElastiCache logs)
# ===============================================================================
resource "aws_kinesis_firehose_delivery_stream" "elasticache_logs" {
  name        = "${local.project}-${local.env}-adf-elc-logs-redis-to-s3"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn           = aws_iam_role.amazon_data_firehose.arn
    bucket_arn         = aws_s3_bucket.elasticache_logs.arn
    buffering_size     = 64
    buffering_interval = 300
    prefix             = "${local.env}/"
    file_extension     = ".json"
    custom_time_zone   = "Asia/Tokyo"
    compression_format = "GZIP"
  }

  server_side_encryption {
    enabled  = true
    key_type = "AWS_OWNED_CMK"
  }

  lifecycle {
    prevent_destroy = false
  }

  depends_on = [
    aws_iam_role_policy_attachment.amazon_data_firehose,
    aws_s3_bucket.elasticache_logs,
  ]

  tags = {
    Name = "${local.project}-${local.env}-adf-elc-logs-redis-to-s3"
  }
}


# ===============================================================================
# Amazon Data Firehose Stream (Amazon ECS logs App)
# ===============================================================================
resource "aws_kinesis_firehose_delivery_stream" "ecs_logs_app" {
  for_each    = local.fargate_app_cloudwatch_log_group
  name        = "${local.project}-${local.env}-adf-ecs-logs-${each.key}-to-s3"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn           = aws_iam_role.amazon_data_firehose.arn
    bucket_arn         = aws_s3_bucket.ecs_logs.arn
    buffering_size     = 64
    buffering_interval = 300
    prefix             = "${local.env}/${each.key}-logs/"
    file_extension     = ".json"
    custom_time_zone   = "Asia/Tokyo"
    compression_format = "GZIP"
  }

  server_side_encryption {
    enabled  = true
    key_type = "AWS_OWNED_CMK"
  }

  lifecycle {
    prevent_destroy = false
  }

  depends_on = [
    aws_iam_role_policy_attachment.amazon_data_firehose,
    aws_s3_bucket.ecs_logs,
  ]

  tags = {
    Name = "${local.project}-${local.env}-adf-ecs-logs-${each.key}-to-s3"
  }
}


# ===============================================================================
# Amazon Data Firehose Stream (Amazon ECS logs Nginx)
# ===============================================================================
resource "aws_kinesis_firehose_delivery_stream" "ecs_logs_nginx" {
  for_each    = local.fargate_nginx_cloudwatch_log_group
  name        = "${local.project}-${local.env}-adf-ecs-logs-${each.key}-to-s3"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn           = aws_iam_role.amazon_data_firehose.arn
    bucket_arn         = aws_s3_bucket.ecs_logs.arn
    buffering_size     = 64
    buffering_interval = 300
    prefix             = "${local.env}/${each.key}-logs/"
    file_extension     = ".json"
    custom_time_zone   = "Asia/Tokyo"
    compression_format = "GZIP"
  }

  server_side_encryption {
    enabled  = true
    key_type = "AWS_OWNED_CMK"
  }

  lifecycle {
    prevent_destroy = false
  }

  depends_on = [
    aws_iam_role_policy_attachment.amazon_data_firehose,
    aws_s3_bucket.ecs_logs,
  ]

  tags = {
    Name = "${local.project}-${local.env}-adf-ecs-logs-${each.key}-to-s3"
  }
}


# ===============================================================================
# Amazon Data Firehose Stream (AWS Lambda logs)
# ===============================================================================
resource "aws_kinesis_firehose_delivery_stream" "lambda_logs" {
  for_each    = local.lambda_functions
  name        = "${local.project}-${local.env}-adf-lmd-logs-${each.key}-to-s3"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn           = aws_iam_role.amazon_data_firehose.arn
    bucket_arn         = aws_s3_bucket.lambda_logs.arn
    buffering_size     = 64
    buffering_interval = 300
    prefix             = "${local.env}/${each.key}-logs/"
    file_extension     = ".json"
    custom_time_zone   = "Asia/Tokyo"
    compression_format = "GZIP"
  }

  server_side_encryption {
    enabled  = true
    key_type = "AWS_OWNED_CMK"
  }

  lifecycle {
    prevent_destroy = false
  }

  depends_on = [
    aws_iam_role_policy_attachment.amazon_data_firehose,
    aws_s3_bucket.lambda_logs,
  ]

  tags = {
    Name = "${local.project}-${local.env}-adf-lmd-logs-${each.key}-to-s3"
  }
}


# ===============================================================================
# Amazon Data Firehose Stream (Amazon SES logs)
# ===============================================================================
resource "aws_kinesis_firehose_delivery_stream" "ses_logs" {
  name        = "${local.project}-${local.env}-adf-ses-logs-to-s3"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn           = aws_iam_role.amazon_data_firehose.arn
    bucket_arn         = aws_s3_bucket.ses_logs.arn
    buffering_size     = 64
    buffering_interval = 300
    prefix             = "${local.env}/ses-logs/"
    file_extension     = ".json"
    custom_time_zone   = "Asia/Tokyo"
    compression_format = "GZIP"
  }

  server_side_encryption {
    enabled  = true
    key_type = "AWS_OWNED_CMK"
  }

  lifecycle {
    prevent_destroy = false
  }

  depends_on = [
    aws_iam_role_policy_attachment.amazon_data_firehose,
    aws_s3_bucket.ses_logs,
  ]

  tags = {
    Name = "${local.project}-${local.env}-adf-ses-logs-to-s3"
  }
}


# ===============================================================================
# Amazon Data Firehose Stream (Amazon SES event logs)
# ===============================================================================
resource "aws_kinesis_firehose_delivery_stream" "ses_event_logs" {
  name        = "${local.project}-${local.env}-adf-ses-event-logs-to-s3"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn           = aws_iam_role.amazon_data_firehose.arn
    bucket_arn         = aws_s3_bucket.ses_logs.arn
    buffering_size     = 64
    buffering_interval = 300
    prefix             = "${local.env}/ses-event-logs/"
    file_extension     = ".json"
    custom_time_zone   = "Asia/Tokyo"
    compression_format = "GZIP"

    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = aws_cloudwatch_log_group.ses.name
      log_stream_name = aws_cloudwatch_log_stream.ses.name
    }
  }

  server_side_encryption {
    enabled  = true
    key_type = "AWS_OWNED_CMK"
  }

  lifecycle {
    prevent_destroy = false
  }

  depends_on = [
    aws_iam_role_policy_attachment.amazon_data_firehose,
    aws_s3_bucket.ses_logs,
  ]

  tags = {
    Name = "${local.project}-${local.env}-adf-ses-event-logs-to-s3"
  }
}


# ===============================================================================
# Amazon Data Firehose Stream (Amazon SNS logs)
# ===============================================================================
resource "aws_kinesis_firehose_delivery_stream" "sns_logs" {
  name        = "${local.project}-${local.env}-adf-sns-logs-to-s3"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn           = aws_iam_role.amazon_data_firehose.arn
    bucket_arn         = aws_s3_bucket.sns_logs.arn
    buffering_size     = 64
    buffering_interval = 300
    prefix             = "${local.env}/sns-logs/"
    file_extension     = ".json"
    custom_time_zone   = "Asia/Tokyo"
    compression_format = "GZIP"
  }

  server_side_encryption {
    enabled  = true
    key_type = "AWS_OWNED_CMK"
  }

  lifecycle {
    prevent_destroy = false
  }

  depends_on = [
    aws_iam_role_policy_attachment.amazon_data_firehose,
    aws_s3_bucket.sns_logs,
  ]

  tags = {
    Name = "${local.project}-${local.env}-adf-sns-logs-to-s3"
  }
}


# ===============================================================================
# Amazon Data Firehose Stream (Amazon SNS Event logs)
# ===============================================================================
resource "aws_kinesis_firehose_delivery_stream" "sns_event_logs" {
  name        = "${local.project}-${local.env}-adf-sns-event-logs-to-s3"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn           = aws_iam_role.amazon_data_firehose.arn
    bucket_arn         = aws_s3_bucket.sns_logs.arn
    buffering_size     = 64
    buffering_interval = 300
    prefix             = "${local.env}/sns-event-logs/"
    file_extension     = ".json"
    custom_time_zone   = "Asia/Tokyo"
    compression_format = "GZIP"
  }

  server_side_encryption {
    enabled  = true
    key_type = "AWS_OWNED_CMK"
  }

  lifecycle {
    prevent_destroy = false
  }

  depends_on = [
    aws_iam_role_policy_attachment.amazon_data_firehose,
    aws_s3_bucket.sns_logs,
  ]

  tags = {
    Name = "${local.project}-${local.env}-adf-sns-event-logs-to-s3"
  }
}


# ===============================================================================
# Amazon Data Firehose Stream (Amazon EC2 Bastion logs)
# ===============================================================================
resource "aws_kinesis_firehose_delivery_stream" "bastion_logs" {
  name        = "${local.project}-${local.env}-adf-ec2-bastion-logs-to-s3"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn           = aws_iam_role.amazon_data_firehose.arn
    bucket_arn         = aws_s3_bucket.bastion.arn
    buffering_size     = 64
    buffering_interval = 300
    prefix             = "${local.env}/ec2-bastion-logs/"
    file_extension     = ".json"
    custom_time_zone   = "Asia/Tokyo"
    compression_format = "GZIP"
  }

  server_side_encryption {
    enabled  = true
    key_type = "AWS_OWNED_CMK"
  }

  lifecycle {
    prevent_destroy = false
  }

  depends_on = [
    aws_iam_role_policy_attachment.amazon_data_firehose,
    aws_s3_bucket.bastion,
  ]

  tags = {
    Name = "${local.project}-${local.env}-adf-ec2-bastion-logs-to-s3"
  }
}
