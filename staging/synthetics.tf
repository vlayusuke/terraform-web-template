# ===============================================================================
# Amazon CloudWatch Synthetics Group
# ===============================================================================
resource "aws_synthetics_group" "main" {
  name = "${local.project}-${local.env}-cwt-syn-group"

  tags = {
    Name = "${local.project}-${local.env}-cwt-syn-group"
  }
}

resource "aws_synthetics_group_association" "check_access_top_page" {
  group_name = aws_synthetics_group.main.name
  canary_arn = aws_synthetics_canary.check_access_top_page.arn
}

resource "aws_synthetics_group_association" "check_input_top_page" {
  group_name = aws_synthetics_group.main.name
  canary_arn = aws_synthetics_canary.check_input_top_page.arn
}


# ===============================================================================
# Amazon CloudWatch Synthetics Canary for Check Access Top Page Monitoring
# ===============================================================================
resource "aws_synthetics_canary" "check_access_top_page" {
  name                     = "${local.project}-${local.env}-cwt-syn-check-access-top-page"
  artifact_s3_location     = aws_s3_bucket.synthetics_artifacts.arn
  execution_role_arn       = aws_iam_role.cloudwatch_synthetics.arn
  handler                  = "function.canary_handler"
  runtime_version          = "syn-python-selenium-11.1"
  zip_file                 = data.archive_file.canary_check_access_top_page.output_path
  success_retention_period = 31
  failure_retention_period = 31

  schedule {
    duration_in_seconds = 0
    expression          = "rate(5 minutes)"
  }

  artifact_config {
    s3_encryption {
      encryption_mode = "SSE_KMS"
      kms_key_arn     = aws_kms_key.synthetics.arn
    }
  }

  run_config {
    active_tracing     = false
    timeout_in_seconds = 60
    ephemeral_storage  = 2048
  }

  depends_on = [
    aws_s3_bucket.synthetics_artifacts,
    aws_iam_role_policy_attachment.cloudwatch_synthetics,
    aws_kms_key.synthetics,
  ]

  tags = {
    Name = "${local.project}-${local.env}-cwt-syn-check-access-top-page"
  }
}

data "archive_file" "canary_check_access_top_page" {
  type        = "zip"
  source_dir  = "${path.cwd}/files/canary/canary-check-access-top-page"
  output_path = "${path.module}/artifacts/canary-check-access-top-page.zip"
}


# ===============================================================================
# Amazon CloudWatch Synthetics Canary for Check Input Top Page Monitoring
# ===============================================================================
resource "aws_synthetics_canary" "check_input_top_page" {
  name                     = "${local.project}-${local.env}-cwt-syn-check-input-top-page"
  artifact_s3_location     = aws_s3_bucket.synthetics_artifacts.arn
  execution_role_arn       = aws_iam_role.cloudwatch_synthetics.arn
  handler                  = "function.canary_handler"
  runtime_version          = "syn-python-selenium-11.1"
  zip_file                 = data.archive_file.canary_check_input_top_page.output_path
  success_retention_period = 31
  failure_retention_period = 31

  schedule {
    duration_in_seconds = 0
    expression          = "rate(5 minutes)"
  }

  artifact_config {
    s3_encryption {
      encryption_mode = "SSE_KMS"
      kms_key_arn     = aws_kms_key.synthetics.arn
    }
  }

  run_config {
    active_tracing     = false
    timeout_in_seconds = 60
    ephemeral_storage  = 2048
  }

  depends_on = [
    aws_s3_bucket.synthetics_artifacts,
    aws_iam_role_policy_attachment.cloudwatch_synthetics,
    aws_kms_key.synthetics,
  ]

  tags = {
    Name = "${local.project}-${local.env}-cwt-syn-check-input-top-page"
  }
}

data "archive_file" "canary_check_input_top_page" {
  type        = "zip"
  source_dir  = "${path.cwd}/files/canary/canary-check-input-top-page"
  output_path = "${path.module}/artifacts/canary-check-input-top-page.zip"
}
