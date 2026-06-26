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
  production_state_file = "production.terraform.tfstate"
  staging_state_file    = "staging.terraform.tfstate"
  develop_state_file    = "develop.terraform.tfstate"
  audit_state_file      = "audit.terraform.tfstate"
  root_state_file       = "terraform.tfstate"

  # region
  region        = "ap-northeast-1"
  dr_region     = "ap-northeast-3"
  global_region = "us-east-1"

  # availability zones
  availability_zones = [
    "ap-northeast-1a",
    "ap-northeast-1c",
  ]

  # domain
  domain = "app.vlayusuke.net"

  # database info
  database_name             = "tf-web"
  database_master_user_name = "admin"
}
