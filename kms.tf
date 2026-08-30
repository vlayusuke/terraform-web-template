# ===============================================================================
# AWS KMS for AWS CodeCommit
# ===============================================================================
resource "aws_kms_key" "codecommit" {
  description             = "${local.project}-${local.env}-kms-cmt-key"
  enable_key_rotation     = true
  deletion_window_in_days = 7

  tags = {
    Name = "${local.project}-${local.env}-kms-cmt-key"
  }
}
