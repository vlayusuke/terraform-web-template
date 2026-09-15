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


# ================================================================================
# AWS CodeCommit Approval Rule
# ================================================================================
resource "aws_codecommit_approval_rule_template" "codecommit_approval_rule" {
  name        = "${local.project}-${local.env}-cmt-approval-rule"
  description = "Approval rule template for ${local.repository} project."

  content = jsonencode({
    Version               = "2018-11-08"
    DestinationReferences = ["refs/heads/main"]
    Statement = [
      {
        Type                    = "Approvers"
        NumberOfApprovalsNeeded = 1
        ApprovalPoolMembers = [
          "arn:aws:sts::${data.aws_caller_identity.current.account_id}:assumed-role/CodeCommitReviewersRole/*"
        ]
      }
    ]
  })
}

resource "aws_codecommit_approval_rule_template_association" "codecommit_approval_rule_association" {
  approval_rule_template_name = aws_codecommit_approval_rule_template.codecommit_approval_rule.name
  repository_name             = aws_codecommit_repository.codecommit.repository_name
}
