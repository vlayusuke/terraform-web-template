# ================================================================================
# AWS Data Lifecycle Manager Configuration for Amazon EBS Volume Backup
# ================================================================================
resource "aws_dlm_lifecycle_policy" "ebs_backup_policy" {
  description        = "${local.project}-${local.env}-dlm-ebs-backup-policy"
  state              = "ENABLED"
  execution_role_arn = aws_iam_role.dlm.arn

  policy_details {
    resource_types = [
      "VOLUME",
    ]

    resource_locations = [
      "CLOUD",
    ]

    target_tags = {
      Backup = "true"
    }

    schedule {
      name = "${local.project}-${local.env}-dlm-daily-backup-schedule"

      tags_to_add = {
        CreatedBy = "${local.project}-${local.env}-dlm-ebs-daily-backup"
      }

      create_rule {
        interval      = 24
        interval_unit = "HOURS"
        times = [
          "20:00",
        ]
      }

      retain_rule {
        count = 7
      }
    }
  }

  lifecycle {
    ignore_changes = [
      state,
    ]
  }

  tags = {
    Name = "${local.project}-${local.env}-dlm-ebs-backup-policy"
  }
}
