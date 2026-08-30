# ================================================================================
# AWS CodeCommit Repository
# ================================================================================
resource "aws_codecommit_repository" "codecommit" {
  repository_name = "${local.project}-${local.env}-cmt-${trimprefix(local.repository, "${local.repository_name}/")}"
  description     = "CodeCommit repository for ${local.repository} project."
  default_branch  = "main"
  kms_key_id      = aws_kms_key.codecommit.arn

  tags = {
    Name = "${local.project}-${local.env}-cmt-${trimprefix(local.repository, "${local.repository_name}/")}"
  }
}
