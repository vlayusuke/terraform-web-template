# ===============================================================================
# SSM Parameters for Application
# ===============================================================================
resource "aws_ssm_parameter" "app_key" {
  name        = "/${local.project}/${local.env}/app-key"
  description = "The parameter for ${local.project}-${local.env} app key"
  key_id      = aws_kms_key.application.key_id
  type        = "SecureString"
  value       = "PleaseChange!"

  lifecycle {
    ignore_changes = [
      value,
    ]
  }

  depends_on = [
    aws_kms_key.application,
  ]

  tags = {
    Name = "${local.project}-${local.env}-ssm-app-key"
  }
}

resource "aws_ssm_parameter" "jwt_secret" {
  name        = "/${local.project}/${local.env}/jwt-secret"
  description = "The parameter for ${local.project}-${local.env} jwt secret"
  key_id      = aws_kms_key.application.key_id
  type        = "SecureString"
  value       = "PleaseChange!"

  lifecycle {
    ignore_changes = [
      value,
    ]
  }

  depends_on = [
    aws_kms_key.application,
  ]

  tags = {
    Name = "${local.project}-${local.env}-ssm-jwt-secret"
  }
}

resource "aws_ssm_parameter" "aurora_writer_endpoint" {
  name        = "/${local.project}/${local.env}/aurora-writer-endpoint"
  description = "The parameter for ${local.project}-${local.env} Amazon Aurora writer endpoint"
  key_id      = aws_kms_key.application.key_id
  type        = "SecureString"
  value       = "PleaseChange!"

  lifecycle {
    ignore_changes = [
      value,
    ]
  }

  depends_on = [
    aws_kms_key.application,
  ]

  tags = {
    Name = "${local.project}-${local.env}-ssm-aur-writer-endpoint"
  }
}

resource "aws_ssm_parameter" "aurora_reader_endpoint" {
  name        = "/${local.project}/${local.env}/aurora-reader-endpoint"
  description = "The parameter for ${local.project}-${local.env} Amazon Aurora reader endpoint"
  key_id      = aws_kms_key.application.key_id
  type        = "SecureString"
  value       = "PleaseChange!"

  lifecycle {
    ignore_changes = [
      value,
    ]
  }

  depends_on = [
    aws_kms_key.application,
  ]

  tags = {
    Name = "${local.project}-${local.env}-ssm-aur-reader-endpoint"
  }
}

resource "aws_ssm_parameter" "elasticache_writer_endpoint" {
  name        = "/${local.project}/${local.env}/elasticache-writer-endpoint"
  description = "The parameter for ${local.project}-${local.env} Amazon ElastiCache writer endpoint"
  key_id      = aws_kms_key.application.key_id
  type        = "SecureString"
  value       = "PleaseChange!"

  lifecycle {
    ignore_changes = [
      value,
    ]
  }

  depends_on = [
    aws_kms_key.application,
  ]

  tags = {
    Name = "${local.project}-${local.env}-ssm-elc-writer-endpoint"
  }
}

resource "aws_ssm_parameter" "elasticache_reader_endpoint" {
  name        = "/${local.project}/${local.env}/elasticache-reader-endpoint"
  description = "The parameter for ${local.project}-${local.env} Amazon ElastiCache reader endpoint"
  key_id      = aws_kms_key.application.key_id
  type        = "SecureString"
  value       = "PleaseChange!"

  lifecycle {
    ignore_changes = [
      value,
    ]
  }

  depends_on = [
    aws_kms_key.application,
  ]

  tags = {
    Name = "${local.project}-${local.env}-ssm-elc-reader-endpoint"
  }
}
