# ===============================================================================
# AWS CloudTrail
# ===============================================================================
resource "aws_cloudtrail" "audit" {
  name                          = "${local.project}-${local.env}-ctl-audit"
  region                        = local.region
  s3_bucket_name                = aws_s3_bucket.cloudtrail_logs.id
  enable_logging                = true
  enable_log_file_validation    = true
  include_global_service_events = true
  is_multi_region_trail         = true
  kms_key_id                    = aws_kms_key.cloudtrail.arn
  cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail.arn
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
  sns_topic_name                = aws_sns_topic.event_notifications_audit.name

  event_selector {
    read_write_type           = "All"
    include_management_events = true

    data_resource {
      type = "AWS::S3::Object"
      values = [
        "${aws_s3_bucket.cloudtrail_logs.arn}/*",
      ]
    }
  }

  depends_on = [
    aws_s3_bucket.cloudtrail_logs,
    aws_s3_bucket_policy.cloudtrail_logs,
  ]

  tags = {
    Name = "${local.project}-${local.env}-ctl-audit"
  }
}
