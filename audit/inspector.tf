# ===============================================================================
# Amazon Inspector v2 (ap-northeast-1)
# ===============================================================================
resource "aws_inspector2_enabler" "default" {
  account_ids = [
    data.aws_caller_identity.current.account_id,
  ]
  resource_types = [
    "EC2",
    "ECR",
    "LAMBDA",
    "LAMBDA_CODE",
  ]
}


# ===============================================================================
# Amazon Inspector v2 (us-east-1)
# ===============================================================================
resource "aws_inspector2_enabler" "global" {
  provider = aws.virginia
  account_ids = [
    data.aws_caller_identity.current.account_id,
  ]
  resource_types = [
    "LAMBDA",
    "LAMBDA_CODE",
  ]
}
