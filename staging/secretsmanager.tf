# ===============================================================================
# AWS Secrets Manager for Docker Hub Credentials
# ===============================================================================
resource "aws_secretsmanager_secret" "dockerhub" {
  name                    = "${local.project}-${local.env}-smg-dockerhub-credentials"
  description             = "Docker Hub credentials for ${local.project}-${local.env}"
  kms_key_id              = aws_kms_key.application.arn
  recovery_window_in_days = 7

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
}
