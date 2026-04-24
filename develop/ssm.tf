# ===============================================================================
# SSM Parameters for MySQL
# ===============================================================================
resource "aws_ssm_parameter" "mysql_password" {
  name        = "/${local.project}/${local.env}/mysql-password"
  description = "The parameter for MySQL password"
  key_id      = aws_kms_key.application.key_id
  type        = "SecureString"
  value       = "PleaseChange!"

  lifecycle {
    ignore_changes = [
      value,
    ]
  }

  tags = {
    Name = "${local.project}-${local.env}-ssm-mysql-password"
  }
}


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

  tags = {
    Name = "${local.project}-${local.env}-ssm-aurora-writer-endpoint"
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

  tags = {
    Name = "${local.project}-${local.env}-ssm-aurora-reader-endpoint"
  }
}

resource "aws_ssm_parameter" "ec_writer_endpoint" {
  name        = "/${local.project}/${local.env}/ec-writer-endpoint"
  description = "The parameter for ${local.project}-${local.env} Amazon ElastiCache writer endpoint"
  key_id      = aws_kms_key.application.key_id
  type        = "SecureString"
  value       = "PleaseChange!"

  lifecycle {
    ignore_changes = [
      value,
    ]
  }

  tags = {
    Name = "${local.project}-${local.env}-ssm-ec-writer-endpoint"
  }
}

resource "aws_ssm_parameter" "ec_reader_endpoint" {
  name        = "/${local.project}/${local.env}/ec-reader-endpoint"
  description = "The parameter for ${local.project}-${local.env} Amazon ElastiCache reader endpoint"
  key_id      = aws_kms_key.application.key_id
  type        = "SecureString"
  value       = "PleaseChange!"

  lifecycle {
    ignore_changes = [
      value,
    ]
  }

  tags = {
    Name = "${local.project}-${local.env}-ssm-ec-reader-endpoint"
  }
}
