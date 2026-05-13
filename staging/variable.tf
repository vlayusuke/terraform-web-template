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
    "192.168.1.1/32", # Example (IPv4)
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


# ================================================================================
# Amazon CloudFront Key-Value Store Settings
# ================================================================================
variable "basic_auth_username" {
  type      = string
  sensitive = true
}

variable "basic_auth_password" {
  type      = string
  sensitive = true
}
