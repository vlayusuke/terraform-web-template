# ===============================================================================
# Amazon CloudWatch Synthetics Group
# ===============================================================================
resource "aws_synthetics_group" "main" {
  name = "${local.project}-${local.env}-cwt-syn-group"

  tags = {
    Name = "${local.project}-${local.env}-cwt-syn-group"
  }
}


# ===============================================================================
# Amazon CloudWatch Synthetics Canary for Top Page Monitoring
# ===============================================================================
resource "aws_synthetics_canary" "top_page" {
  name                 = "${local.project}-${local.env}-cwt-syn-top-page"
  artifact_s3_location = aws_s3_bucket.synthetics_artifacts.arn
  execution_role_arn   = aws_iam_role.cloudwatch_synthetics.arn
  handler              = "canary_top_page.function.canary_handler"
  runtime_version      = "syn-python-selenium-1.0"
  zip_file             = "artifact/canary-top-page.zip"

  schedule {
    expression = "rate(5 minutes)"
  }

  artifact_config {
    s3_encryption {
      encryption_mode = "SSE_KMS"
      kms_key_arn     = aws_kms_key.synthetics.arn
    }
  }

  tags = {
    Name = "${local.project}-${local.env}-cwt-syn-top-page"
  }
}

data "archive_file" "canary_top_page" {
  type        = "zip"
  source_dir  = "${path.cwd}/files/canary/canary-top-page"
  output_path = "${path.module}/artifacts/canary-top-page.zip"
}
