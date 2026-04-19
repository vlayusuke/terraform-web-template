# ================================================================================
# Base Local Values
# ================================================================================
locals {
  # repository info
  repository = "vlayusuke/terraform-web-template"

  # project info
  project = "tf-web"
  author  = "Yusuke TOMIOKA"
  email   = "vlayusuke@gmail.com"

  # state files
  production_state_file  = "production.terraform.tfstate"
  staging_state_file     = "staging.terraform.tfstate"
  development_state_file = "development.terraform.tfstate"
  audit_state_file       = "audit.terraform.tfstate"
  root_state_file        = "terraform.tfstate"

  # region
  region = "ap-northeast-1"

  # availability zones
  availability_zones = [
    "ap-northeast-1a",
    "ap-northeast-1c",
  ]

  # domain
  domain = "vlayusuke.net"

  # database info
  database_name             = "tf-web"
  database_master_user_name = "admin"
}
