# ================================================================================
# Terraform
# ================================================================================
terraform {
  required_version = ">= 1.10.0, < 2.0.0"

  backend "s3" {
    bucket  = "v-terraform-web-template-stg"
    key     = "state/staging.terraform.tfstate"
    region  = "ap-northeast-1"
    profile = "terraform-template"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.61.0"
    }

    awscc = {
      source  = "hashicorp/awscc"
      version = "1.98.0"
    }
  }
}

data "aws_caller_identity" "current" {}
data "aws_elb_service_account" "main" {}
data "aws_region" "current" {}

provider "aws" {
  region  = "ap-northeast-1"
  profile = "terraform-template"

  default_tags {
    tags = {
      Managed     = "terraform"
      Project     = local.project
      Environment = local.env
      Repository  = local.repository
      Author      = local.author
    }
  }
}

provider "aws" {
  region  = "us-east-1"
  alias   = "virginia"
  profile = "terraform-template"

  default_tags {
    tags = {
      Managed     = "terraform"
      Project     = local.project
      Environment = local.env
      Repository  = local.repository
      Author      = local.author
    }
  }
}

provider "aws" {
  region  = "ap-northeast-3"
  alias   = "osaka"
  profile = "terraform-template"

  default_tags {
    tags = {
      Managed     = "terraform"
      Project     = local.project
      Environment = local.env
      Repository  = local.repository
      Author      = local.author
    }
  }
}

provider "awscc" {
  region  = "ap-northeast-1"
  profile = "terraform-template"
}
