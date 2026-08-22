# ===============================================================================
# Amazon GuardDuty Detector
# ===============================================================================
resource "aws_guardduty_detector" "main" {
  enable                       = true
  finding_publishing_frequency = "SIX_HOURS"

  tags = {
    Name = "${local.project}-${local.env}-gdt-detector"
  }
}


# ===============================================================================
# Amazon GuardDuty Detector Features
# ===============================================================================
resource "aws_guardduty_detector_feature" "s3_data_events" {
  detector_id = aws_guardduty_detector.main.id
  name        = "S3_DATA_EVENTS"
  status      = "ENABLED"
}

resource "aws_guardduty_detector_feature" "rds_login_events" {
  detector_id = aws_guardduty_detector.main.id
  name        = "RDS_LOGIN_EVENTS"
  status      = "ENABLED"
}

resource "aws_guardduty_detector_feature" "ebs_malware_protection" {
  detector_id = aws_guardduty_detector.main.id
  name        = "EBS_MALWARE_PROTECTION"
  status      = "ENABLED"
}

resource "aws_guardduty_detector_feature" "lambda_network_logs" {
  detector_id = aws_guardduty_detector.main.id
  name        = "LAMBDA_NETWORK_LOGS"
  status      = "ENABLED"
}

resource "aws_guardduty_detector_feature" "runtime_monitoring" {
  detector_id = aws_guardduty_detector.main.id
  name        = "RUNTIME_MONITORING"
  status      = "ENABLED"

  additional_configuration {
    name   = "ECS_FARGATE_AGENT_MANAGEMENT"
    status = "ENABLED"
  }
}


# ===============================================================================
# Amazon GuardDuty Publishing Destination
# ===============================================================================
resource "aws_guardduty_publishing_destination" "main" {
  detector_id      = aws_guardduty_detector.main.id
  destination_arn  = aws_s3_bucket.guardduty_logs.arn
  kms_key_arn      = aws_kms_key.guardduty.arn
  destination_type = "S3"

  depends_on = [
    aws_guardduty_detector.main,
    aws_s3_bucket.guardduty_logs,
    aws_kms_key.guardduty,
  ]

  tags = {
    Name = "${local.project}-${local.env}-gdt-publishing-destination"
  }
}
