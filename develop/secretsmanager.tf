# ===============================================================================
# AWS Secrets Manager for Docker Hub Credentials
# ===============================================================================
resource "aws_secretsmanager_secret" "dockerhub" {
  name                    = "${local.project}-${local.env}-smg-dockerhub-credentials"
  description             = "Docker Hub credentials for ${local.project}-${local.env}"
  kms_key_id              = aws_kms_key.application.arn
  recovery_window_in_days = 7

  depends_on = [
    aws_kms_key.application,
  ]

  tags = {
    Name = "${local.project}-${local.env}-smg-dockerhub-credentials"
  }
}

resource "aws_secretsmanager_secret_version" "dockerhub" {
  secret_id = aws_secretsmanager_secret.dockerhub.id
  secret_string = jsonencode({
    username = var.dockerhub_username
    password = var.dockerhub_password
  })

  lifecycle {
    ignore_changes = [
      secret_string,
    ]
  }
}

resource "aws_secretsmanager_secret_rotation" "dockerhub" {
  secret_id        = aws_secretsmanager_secret.dockerhub.id
  rotation_enabled = false
}


# ===============================================================================
# AWS Secrets Manager for MySQL Credentials
# ===============================================================================
resource "aws_secretsmanager_secret" "mysql" {
  name                    = "${local.project}-${local.env}-smg-mysql-credentials"
  description             = "MySQL credentials for ${local.project}-${local.env}"
  kms_key_id              = aws_kms_key.aurora.arn
  recovery_window_in_days = 7

  depends_on = [
    aws_kms_key.aurora,
  ]

  tags = {
    Name = "${local.project}-${local.env}-smg-mysql-credentials"
  }
}

resource "aws_secretsmanager_secret_version" "mysql" {
  secret_id = aws_secretsmanager_secret.mysql.id
  secret_string = jsonencode({
    username = var.mysql_username
    password = var.mysql_password
  })

  lifecycle {
    ignore_changes = [
      secret_string,
    ]
  }
}

resource "aws_secretsmanager_secret_rotation" "mysql" {
  secret_id        = aws_rds_cluster.aurora.master_user_secret[0].secret_arn
  rotation_enabled = false

  depends_on = [
    aws_rds_cluster.aurora,
  ]
}
