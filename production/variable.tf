# ================================================================================
# Slack & AWS Chatbot Settings
# ================================================================================
variable "hook_url_app" {
  type      = string
  sensitive = true
}

variable "slack_workspace_id" {
  sensitive = true
}

variable "slack_channel_id" {
  sensitive = true
}


# ================================================================================
# Amazon EC2 Bastion Settings
# ================================================================================
variable "aws_key_pub_bastion" {
  sensitive = true
}

variable "maintenance_ips" {
  sensitive = true
  default = [
    "60.67.101.143/32", # Home (IPv4)
  ]
}


# ================================================================================
# AWS Secrets Manager Settings
# ================================================================================
variable "dockerhub_username" {
  type      = string
  sensitive = true
}

variable "dockerhub_password" {
  type      = string
  sensitive = true
}
