# ===============================================================================
# AWS Chatbot (Amazon Q Developer)
# ===============================================================================
resource "aws_chatbot_slack_channel_configuration" "chatbot_audit_notifications_for_slack" {
  configuration_name          = "${local.project}-${local.env}-chatbot-notifications-for-slack"
  iam_role_arn                = aws_iam_role.chatbot_audit.arn
  slack_channel_id            = var.audit_slack_channel_id
  slack_team_id               = var.audit_slack_workspace_id
  logging_level               = "INFO"
  user_authorization_required = false

  guardrail_policy_arns = [
    aws_iam_policy.chatbot_audit_guardrail.arn,
  ]

  sns_topic_arns = [
    aws_sns_topic.config_notifications.arn,
    aws_sns_topic.event_notifications_audit.arn,
  ]

  tags = {
    Name = "${local.project}-${local.env}-chatbot-notifications-for-slack"
  }
}
