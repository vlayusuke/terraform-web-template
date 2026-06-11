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

# If you want to use Microsoft Teams, you can use the following resource instead of the above one.
# resource "aws_chatbot_microsoft_teams_channel_configuration" "chatbot_audit_notifications_for_teams" {
#   configuration_name          = "${local.project}-${local.env}-chatbot-notifications-for-teams"
#   iam_role_arn                = aws_iam_role.chatbot_audit.arn
#   microsoft_teams_channel_id   = var.teams_channel_id
#   microsoft_teams_tenant_id    = var.teams_tenant_id
#   logging_level               = "INFO"
#   user_authorization_required = false
#
#   guardrail_policy_arns = [
#     aws_iam_policy.chatbot_audit_guardrail.arn,
#   ]
#
#   sns_topic_arns = [
#     aws_sns_topic.config_notifications.arn,
#     aws_sns_topic.event_notifications_audit.arn,
#   ]
#
#   tags = {
#     Name = "${local.project}-${local.env}-chatbot-notifications-for-teams"
#   }
# }
