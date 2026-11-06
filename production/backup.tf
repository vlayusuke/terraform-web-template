# ===============================================================================
# AWS Backup (for Amazon Aurora at Tokyo and Osaka regions)
# https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-backups.html
# ===============================================================================
resource "aws_backup_vault" "aurora" {
  region        = local.region
  name          = "${local.project}-${local.env}-backup-vault-aurora"
  kms_key_arn   = aws_kms_key.backup_vault.arn
  force_destroy = true

  tags = {
    Name = "${local.project}-${local.env}-backup-vault-aurora"
  }
}

resource "aws_backup_vault_policy" "aurora" {
  backup_vault_name = aws_backup_vault.aurora.name
  policy            = data.aws_iam_policy_document.aurora_backup_vault_policy.json
}

data "aws_iam_policy_document" "aurora_backup_vault_policy" {
  statement {
    sid    = "AllowAccountAccess"
    effect = "Allow"
    actions = [
      "backup:DescribeBackupVault",
      "backup:DeleteBackupVault",
      "backup:PutBackupVaultAccessPolicy",
      "backup:DeleteBackupVaultAccessPolicy",
      "backup:GetBackupVaultAccessPolicy",
      "backup:StartBackupJob",
      "backup:GetBackupVaultNotifications",
      "backup:PutBackupVaultNotifications",
    ]
    resources = [
      aws_backup_vault.aurora.arn,
    ]
    principals {
      type = "AWS"
      identifiers = [
        data.aws_caller_identity.current.account_id,
      ]
    }
  }
}

resource "aws_backup_vault_lock_configuration" "aurora" {
  region              = local.region
  backup_vault_name   = aws_backup_vault.aurora.name
  max_retention_days  = 365
  min_retention_days  = 30
  changeable_for_days = 7
}

resource "aws_backup_plan" "aurora" {
  region = local.region
  name   = "${local.project}-${local.env}-backup-plan-aurora"

  rule {
    rule_name                    = "aurora-backup-rule"
    target_vault_name            = aws_backup_vault.aurora.name
    schedule                     = "cron(0 23 * * ? *)"
    schedule_expression_timezone = "Asia/Tokyo"

    lifecycle {
      delete_after = 365
    }

    copy_action {
      destination_vault_arn = aws_backup_vault.aurora_osaka.arn

      lifecycle {
        delete_after = 365
      }
    }
  }
}

resource "aws_backup_selection" "aurora" {
  region       = local.region
  iam_role_arn = aws_iam_role.backup.arn
  name         = "${local.project}-${local.env}-backup-selection-aurora"
  plan_id      = aws_backup_plan.aurora.id

  resources = [
    aws_rds_cluster.aurora.arn,
    aws_rds_cluster_instance.aurora[*].arn,
  ]
}

resource "aws_backup_region_settings" "aurora" {
  region = local.region

  resource_type_opt_in_preference = {
    "Aurora" = true
  }
}

resource "aws_backup_report_plan" "aurora" {
  region      = local.region
  name        = "${local.project}-${local.env}-backup-report-plan-aurora"
  description = "Backup report plan for AmazonAurora to ap-northeast-3."

  report_delivery_channel {
    formats = [
      "CSV",
      "JSON",
    ]
    s3_bucket_name = aws_s3_bucket.backup_reports.bucket
  }

  report_setting {
    regions = [
      local.region,
    ]
    report_template = "BACKUP_JOB_REPORT"
  }

  tags = {
    Name = "${local.project}-${local.env}-backup-report-plan-aurora"
  }
}

resource "aws_backup_vault_notifications" "aurora" {
  region            = local.region
  backup_vault_name = aws_backup_vault.aurora.name
  sns_topic_arn     = aws_sns_topic.event_notifications.arn
  backup_vault_events = [
    "BACKUP_JOB_STARTED",
    "BACKUP_JOB_COMPLETED",
    "BACKUP_JOB_FAILED",
  ]
}


# ===============================================================================
# AWS Backup (for Amazon Aurora Settings at Osaka region)
# ===============================================================================
resource "aws_backup_vault" "aurora_osaka" {
  provider    = aws.osaka
  name        = "${local.project}-${local.env}-backup-vault-aurora-osaka"
  kms_key_arn = aws_kms_key.backup_vault_osaka.arn

  tags = {
    Name = "${local.project}-${local.env}-backup-vault-aurora-osaka"
  }
}

resource "aws_backup_vault_lock_configuration" "aurora_osaka" {
  provider            = aws.osaka
  backup_vault_name   = aws_backup_vault.aurora_osaka.name
  max_retention_days  = 365
  min_retention_days  = 30
  changeable_for_days = 7
}

resource "aws_backup_region_settings" "aurora_osaka" {
  provider = aws.osaka
  resource_type_opt_in_preference = {
    "Aurora" = true
  }
}
