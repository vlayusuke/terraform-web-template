# ===============================================================================
# Amazon ECR Repository for Nginx (Base Image)
# ===============================================================================
resource "aws_ecr_repository" "nginx_base" {
  name                 = "${local.project}/${local.env}/base/nginx"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = aws_kms_key.ecr.arn
  }

  tags = {
    Name = "${local.project}-${local.env}-ecr-nginx-base"
  }
}

resource "aws_ecr_lifecycle_policy" "nginx_base" {
  repository = aws_ecr_repository.nginx_base.name

  policy = jsonencode({
    "rules" : [
      {
        "rulePriority" : 1,
        "description" : "Keep last 10 images",
        "selection" : {
          "tagStatus" : "any",
          "countType" : "imageCountMoreThan",
          "countNumber" : 10
        },
        "action" : {
          "type" : "expire"
        }
      }
    ]
  })
}


# ===============================================================================
# Amazon ECR Repository for App (Base Image)
# ===============================================================================
resource "aws_ecr_repository" "app_base" {
  name                 = "${local.project}/${local.env}/base/app"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = aws_kms_key.ecr.arn
  }

  tags = {
    Name = "${local.project}-${local.env}-ecr-app-base"
  }
}

resource "aws_ecr_lifecycle_policy" "app_base" {
  repository = aws_ecr_repository.app_base.name

  policy = jsonencode({
    "rules" : [
      {
        "rulePriority" : 1,
        "description" : "Keep last 10 images",
        "selection" : {
          "tagStatus" : "any",
          "countType" : "imageCountMoreThan",
          "countNumber" : 10
        },
        "action" : {
          "type" : "expire"
        }
      }
    ]
  })
}


# ===============================================================================
# Amazon ECR Repository for Nginx
# ===============================================================================
resource "aws_ecr_repository" "nginx" {
  name                 = "${local.project}/${local.env}/nginx"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = aws_kms_key.ecr.arn
  }

  tags = {
    Name = "${local.project}-${local.env}-ecr-nginx"
  }
}

resource "aws_ecr_lifecycle_policy" "nginx" {
  repository = aws_ecr_repository.nginx.name

  policy = jsonencode({
    "rules" : [
      {
        "rulePriority" : 1,
        "description" : "Keep last 10 images",
        "selection" : {
          "tagStatus" : "any",
          "countType" : "imageCountMoreThan",
          "countNumber" : 10
        },
        "action" : {
          "type" : "expire"
        }
      }
    ]
  })
}


# ===============================================================================
# Amazon ECR Repository for App
# ===============================================================================
resource "aws_ecr_repository" "app" {
  name                 = "${local.project}/${local.env}/app"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = aws_kms_key.ecr.arn
  }

  tags = {
    Name = "${local.project}-${local.env}-ecr-app"
  }
}

resource "aws_ecr_lifecycle_policy" "app" {
  repository = aws_ecr_repository.app.name

  policy = jsonencode({
    "rules" : [
      {
        "rulePriority" : 1,
        "description" : "Keep last 10 images",
        "selection" : {
          "tagStatus" : "any",
          "countType" : "imageCountMoreThan",
          "countNumber" : 10
        },
        "action" : {
          "type" : "expire"
        }
      }
    ]
  })
}
