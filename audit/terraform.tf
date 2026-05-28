# ================================================================================
# Terraform
# ================================================================================
terraform {
  required_version = ">= 1.10.0, < 2.0.0"

  backend "s3" {
    # bucket is supplied at terraform init time with -backend-config
    key     = "state/audit.terraform.tfstate"
    region  = "ap-northeast-1"
    profile = "terraform-template"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.47.0"
    }

    awscc = {
      source  = "hashicorp/awscc"
      version = "1.86.0"
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
  region  = "us-east-2"
  alias   = "ohio"
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
  region  = "us-west-1"
  alias   = "california"
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
  region  = "us-west-2"
  alias   = "oregon"
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
  region  = "ap-south-1"
  alias   = "mumbai"
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
  region  = "ap-northeast-2"
  alias   = "seoul"
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

provider "aws" {
  region  = "ap-southeast-1"
  alias   = "singapore"
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
  region  = "ap-southeast-2"
  alias   = "sydney"
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
  region  = "ca-central-1"
  alias   = "canada"
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
  region  = "eu-central-1"
  alias   = "frankfurt"
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
  region  = "eu-west-1"
  alias   = "ileland"
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
  region  = "eu-west-2"
  alias   = "london"
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
  region  = "eu-west-3"
  alias   = "paris"
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
  region  = "eu-north-1"
  alias   = "stockholm"
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
  region  = "sa-east-1"
  alias   = "saopaulo"
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
