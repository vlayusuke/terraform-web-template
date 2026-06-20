# ===============================================================================
# AWS Config
# Reference: https://docs.aws.amazon.com/ja_jp/config/latest/developerguide/resource-config-reference.html
# ===============================================================================
resource "aws_config_configuration_recorder" "default" {
  name     = "${local.project}-${local.env}-aws-cfg-default"
  role_arn = aws_iam_role.config.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }

  recording_mode {
    recording_frequency = "CONTINUOUS"
  }
}

resource "aws_config_delivery_channel" "default" {
  name           = "default"
  s3_bucket_name = aws_s3_bucket.config_logs.bucket
  sns_topic_arn  = aws_sns_topic.event_notifications_audit.arn

  depends_on = [
    aws_config_configuration_recorder.default,
  ]

  snapshot_delivery_properties {
    delivery_frequency = "Six_Hours"
  }
}

resource "aws_config_configuration_recorder_status" "default" {
  name       = aws_config_configuration_recorder.default.name
  is_enabled = true

  depends_on = [
    aws_config_delivery_channel.default,
  ]
}

resource "aws_cloudformation_stack" "operational_best_practices_for_cis" {
  name = "${local.project}-${local.env}-aws-cfg-operational-best-practices-for-cis"

  # commit: 9018e3a3003bde8d8898a2912de64cce39a20b80
  # https://github.com/awslabs/aws-config-rules/blob/master/aws-config-conformance-packs/Operational-Best-Practices-for-CIS.yaml
  template_body = file("./files/config-cloudformation/Operational-Best-Practices-for-CIS.yaml")

  depends_on = [
    aws_config_configuration_recorder.default,
  ]
}

resource "aws_config_config_rule" "s3_bucket_server_side_encryption_enabled" {
  name = "${local.project}-${local.env}-aws-cfg-s3-bucket-sse-enabled"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_SERVER_SIDE_ENCRYPTION_ENABLED"
  }

  depends_on = [
    aws_config_configuration_recorder.default,
  ]
}

resource "aws_config_config_rule" "s3_bucket_versioning_enabled" {
  name = "${local.project}-${local.env}-aws-cfg-s3-bucket-versioning-enabled"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_VERSIONING_ENABLED"
  }

  depends_on = [
    aws_config_configuration_recorder.default,
  ]
}

resource "aws_config_config_rule" "rds_instance_public_access_check" {
  name = "${local.project}-${local.env}-aws-cfg-rds-instance-public-access-check"

  source {
    owner             = "AWS"
    source_identifier = "RDS_INSTANCE_PUBLIC_ACCESS_CHECK"
  }

  depends_on = [
    aws_config_configuration_recorder.default,
  ]
}
