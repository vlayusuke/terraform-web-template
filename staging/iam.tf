# ===============================================================================
# AWS IAM OIDC Provider for GitHub
# ===============================================================================
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  thumbprint_list = [
    data.tls_certificate.github.certificates[0].sha1_fingerprint,
  ]

  client_id_list = [
    "sts.amazonaws.com",
  ]

  tags = {
    Name = "${local.project}-${local.env}-iam-oidc-provider-idp"
  }
}

data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com/.well-known/openid-configuration"
}


# ===============================================================================
# AWS IAM for GitHub Actions Deploy
# ===============================================================================
resource "aws_iam_role" "github_actions_deploy" {
  name               = "${local.project}-${local.env}-iam-github-actions-deploy-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.github_actions_deploy_assume.json

  tags = {
    Name = "${local.project}-${local.env}-iam-github-actions-deploy-role"
  }
}

data "aws_iam_policy_document" "github_actions_deploy_assume" {
  statement {
    sid    = "OIDCFederate"
    effect = "Allow"
    actions = [
      "sts:AssumeRoleWithWebIdentity",
    ]
    principals {
      type = "Federated"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com",
      ]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:${local.repository_name}/*",
      ]
    }
  }

  statement {
    sid    = "OIDCFederateRef"
    effect = "Allow"
    actions = [
      "sts:AssumeRoleWithWebIdentity",
    ]
    principals {
      type = "Federated"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com",
      ]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:${local.repository_name}:ref:refs/heads/main",
        "repo:${local.repository_name}:ref:refs/heads/*",
      ]
    }
  }
}

resource "aws_iam_policy" "github_actions_deploy" {
  name   = "${local.project}-${local.env}-iam-github-actions-deploy-policy"
  policy = data.aws_iam_policy_document.github_actions_deploy.json

  tags = {
    Name = "${local.project}-${local.env}-iam-github-actions-deploy-policy"
  }
}

data "aws_iam_policy_document" "github_actions_deploy" {
  statement {
    sid    = "GetAuthorizationToken"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
    ]
    resources = [
      "*",
    ]
  }

  statement {
    sid    = "PushImageOnly"
    effect = "Allow"
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchCheckLayerAvailability",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:BatchGetImage",
      "ecr:PutImage",
    ]
    resources = [
      aws_ecr_repository.nginx.arn,
      aws_ecr_repository.app.arn,
      aws_ecr_repository.nginx_base.arn,
      aws_ecr_repository.app_base.arn,
    ]
  }

  statement {
    sid    = "RegisterTaskDefinition"
    effect = "Allow"
    actions = [
      "iam:GetRole",
      "events:PutTargets",
      "ecs:RunTask",
      "ecs:RegisterTaskDefinition",
      "ecs:DescribeTaskDefinition",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
    ]
    resources = [
      aws_iam_role.ecs_task.arn,
      aws_subnet.main_private[0].arn,
      aws_subnet.main_private[1].arn,
      aws_security_group.fargate_app.arn,
      aws_security_group.fargate_cron.arn,
      aws_security_group.fargate_queue.arn,
      "${aws_ecs_task_definition.app.arn}:*",
      "${aws_ecs_task_definition.cron.arn}:*",
      "${aws_ecs_task_definition.queue.arn}:*",
      "${aws_ecs_task_definition.migrate.arn}:*",
    ]
  }

  statement {
    sid    = "UpdateService"
    effect = "Allow"
    actions = [
      "ecs:DescribeClusters",
      "ecs:DescribeServices",
      "ecs:DescribeTasks",
      "ecs:UpdateServicePrimaryTaskSet",
      "ecs:UpdateService",
    ]
    resources = [
      aws_ecs_cluster.main.arn,
      aws_ecs_service.app.arn,
      aws_ecs_service.cron.arn,
      aws_ecs_service.queue.arn,
      "${aws_ecs_task_definition.app.arn}:*",
      "${aws_ecs_task_definition.cron.arn}:*",
      "${aws_ecs_task_definition.queue.arn}:*",
      "${aws_ecs_task_definition.migrate.arn}:*",
    ]
  }

  statement {
    sid    = "S3Access"
    effect = "Allow"
    actions = [
      "s3:ListAllMyBuckets",
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = [
      "arn:aws:s3:::${local.project}-${local.env}-*",
      "arn:aws:s3:::${local.project}-${local.env}-*/*",
      "arn:aws:s3:::v-terraform-*",
      "arn:aws:s3:::v-terraform-*/*",
    ]
  }

  statement {
    sid    = "IAMPassRole"
    effect = "Allow"
    actions = [
      "iam:PassRole",
    ]
    resources = [
      aws_iam_role.ecs_service.arn,
      aws_iam_role.ecs_task.arn,
    ]
    condition {
      test     = "StringLike"
      variable = "iam:PassedToService"
      values = [
        "ecs-tasks.amazonaws.com",
        "ecs.amazonaws.com",
      ]
    }
  }

  statement {
    sid    = "GlobalServiceCheck"
    effect = "Allow"
    actions = [
      "acm:DescribeCertificate",
      "wafv2:GetWebACL",
    ]
    resources = [
      "*",
    ]
  }
}

resource "aws_iam_role_policy_attachment" "github_actions_deploy" {
  role       = aws_iam_role.github_actions_deploy.name
  policy_arn = aws_iam_policy.github_actions_deploy.arn
}


# ===============================================================================
# AWS IAM for GitHub Actions Backup
# ===============================================================================
resource "aws_iam_role" "github_actions_backup" {
  name               = "${local.project}-${local.env}-iam-github-actions-backup-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.github_actions_backup_assume.json

  tags = {
    Name = "${local.project}-${local.env}-iam-github-actions-backup-role"
  }
}

data "aws_iam_policy_document" "github_actions_backup_assume" {
  statement {
    sid    = "OIDCFederate"
    effect = "Allow"
    actions = [
      "sts:AssumeRoleWithWebIdentity",
    ]
    principals {
      type = "Federated"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com",
      ]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:${local.repository_name}/*",
      ]
    }
  }

  statement {
    sid    = "OIDCFederateRef"
    effect = "Allow"
    actions = [
      "sts:AssumeRoleWithWebIdentity",
    ]
    principals {
      type = "Federated"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com",
      ]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:${local.repository_name}:ref:refs/heads/main",
        "repo:${local.repository_name}:ref:refs/heads/*",
      ]
    }
  }
}

resource "aws_iam_policy" "github_actions_backup" {
  name   = "${local.project}-${local.env}-iam-github-actions-backup-policy"
  policy = data.aws_iam_policy_document.github_actions_backup.json

  tags = {
    Name = "${local.project}-${local.env}-iam-github-actions-backup-policy"
  }
}

data "aws_iam_policy_document" "github_actions_backup" {
  statement {
    sid    = "GetAuthorizationToken"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
    ]
    resources = [
      aws_ecr_repository.nginx.arn,
      aws_ecr_repository.app.arn,
      aws_ecr_repository.nginx_base.arn,
      aws_ecr_repository.app_base.arn,
    ]
  }

  statement {
    sid    = "S3Access"
    effect = "Allow"
    actions = [
      "s3:ListAllMyBuckets",
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = [
      "arn:aws:s3:::${local.project}-*-*",
      "arn:aws:s3:::${local.project}-*-*/*",
    ]
  }
}

resource "aws_iam_role_policy_attachment" "github_actions_backup" {
  role       = aws_iam_role.github_actions_backup.name
  policy_arn = aws_iam_policy.github_actions_backup.arn
}


# ===============================================================================
# AWS IAM for Amazon ECS Service
# ===============================================================================
resource "aws_iam_role" "ecs_service" {
  name               = "${local.project}-${local.env}-iam-ecs-service-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ecs_service_assume.json

  tags = {
    Name = "${local.project}-${local.env}-iam-ecs-service-role"
  }
}

data "aws_iam_policy_document" "ecs_service_assume" {
  statement {
    sid    = "ECSAssume"
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "Service"
      identifiers = [
        "ecs.amazonaws.com",
        "ecs-tasks.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_policy" "ecs_service" {
  name   = "${local.project}-${local.env}-iam-ecs-service-policy"
  policy = data.aws_iam_policy_document.ecs_service.json

  tags = {
    Name = "${local.project}-${local.env}-iam-ecs-service-policy"
  }
}

data "aws_iam_policy_document" "ecs_service" {
  statement {
    sid    = "PassRole"
    effect = "Allow"
    actions = [
      "iam:PassRole",
    ]
    resources = [
      aws_iam_role.ecs_service.arn,
      aws_iam_role.ecs_task.arn,
    ]
  }

  statement {
    sid    = "GetKeyAndParam"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "ssm:GetParameters",
      "ssm:GetParameter",
    ]
    resources = [
      aws_kms_key.application.arn,
      aws_kms_key.aurora.arn,
      aws_ssm_parameter.mysql_password.arn,
      aws_ssm_parameter.jwt_secret.arn,
      aws_ssm_parameter.app_key.arn,
      aws_ssm_parameter.aurora_writer_endpoint.arn,
      aws_ssm_parameter.aurora_reader_endpoint.arn,
      aws_ssm_parameter.elasticache_writer_endpoint.arn,
      aws_ssm_parameter.elasticache_reader_endpoint.arn,
    ]
  }

  statement {
    sid    = "ADFAccess"
    effect = "Allow"
    actions = [
      "firehose:PutRecord",
      "firehose:PutRecordBatch",
    ]
    resources = [
      aws_kinesis_firehose_delivery_stream.ecs_logs_app["app-app"].arn,
      aws_kinesis_firehose_delivery_stream.ecs_logs_app["cron"].arn,
      aws_kinesis_firehose_delivery_stream.ecs_logs_app["queue"].arn,
      aws_kinesis_firehose_delivery_stream.ecs_logs_app["migrate"].arn,
      aws_kinesis_firehose_delivery_stream.ecs_logs_nginx["app-nginx"].arn,
    ]
  }

  statement {
    sid    = "GetDockerHubCredentials"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "secretsmanager:GetSecretValue",
    ]
    resources = [
      aws_kms_key.application.arn,
      "arn:aws:secretsmanager:${local.region}:${data.aws_caller_identity.current.account_id}:secret:${local.project}-${local.env}-smg-dockerhub-credentials*",
    ]
  }
}

resource "aws_iam_role_policy_attachment" "ecs_service" {
  role       = aws_iam_role.ecs_service.name
  policy_arn = aws_iam_policy.ecs_service.arn
}

resource "aws_iam_role_policy_attachment" "ecs_task_exec_to_ecs_service" {
  role       = aws_iam_role.ecs_service.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


# ===============================================================================
# AWS IAM for Amazon ECS Task
# ===============================================================================
resource "aws_iam_role" "ecs_task" {
  name               = "${local.project}-${local.env}-iam-ecs-task-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume.json

  tags = {
    Name = "${local.project}-${local.env}-iam-ecs-task-role"
  }
}

data "aws_iam_policy_document" "ecs_task_assume" {
  statement {
    sid    = "ECSAssume"
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "Service"
      identifiers = [
        "ecs.amazonaws.com",
        "ecs-tasks.amazonaws.com",
        "delivery.logs.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_policy" "ecs_task" {
  name   = "${local.project}-${local.env}-iam-ecs-task-policy"
  policy = data.aws_iam_policy_document.ecs_task.json

  tags = {
    Name = "${local.project}-${local.env}-iam-ecs-task-policy"
  }
}

data "aws_iam_policy_document" "ecs_task" {
  statement {
    sid    = "PassRole"
    effect = "Allow"
    actions = [
      "iam:PassRole",
    ]
    resources = [
      aws_iam_role.ecs_service.arn,
      aws_iam_role.ecs_task.arn,
    ]
  }

  statement {
    sid    = "ECSAccess"
    effect = "Allow"
    actions = [
      "ecs:RunTask",
      "ecs:ListTaskDefinitions",
      "ecs:DescribeServices",
    ]
    resources = [
      "${aws_ecs_task_definition.app.arn}:*",
      "${aws_ecs_task_definition.cron.arn}:*",
      "${aws_ecs_task_definition.queue.arn}:*",
      "${aws_ecs_task_definition.migrate.arn}:*",
    ]
  }

  statement {
    sid    = "EFSAccess"
    effect = "Allow"
    actions = [
      "elasticfilesystem:ClientMount",
      "elasticfilesystem:ClientRead",
      "elasticfilesystem:ClientWrite",
    ]
    resources = [
      aws_efs_file_system.main.arn,
    ]
  }

  statement {
    sid    = "AuroraAccess"
    effect = "Allow"
    actions = [
      "rds-db:connect",
      "rds-data:ExecuteStatement",
    ]
    resources = [
      "arn:aws:rds:${local.region}:${data.aws_caller_identity.current.account_id}:db:*",
    ]
  }

  statement {
    sid    = "S3Access"
    effect = "Allow"
    actions = [
      "s3:ListAllMyBuckets",
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = [
      "arn:aws:s3:::${local.project}-${local.env}-*",
    ]
  }

  statement {
    sid    = "SendMail"
    effect = "Allow"
    actions = [
      "ses:SendEmail",
      "ses:SendRawEmail",
    ]
    resources = [
      "arn:aws:ses:${local.region}:${data.aws_caller_identity.current.account_id}:identity/*",
      aws_ses_configuration_set.main_event.arn,
    ]
  }

  statement {
    sid    = "LogAccess"
    effect = "Allow"
    actions = [
      "logs:CreateLogDelivery",
      "logs:GetLogDelivery",
      "logs:UpdateLogDelivery",
      "logs:DeleteLogDelivery",
      "logs:ListLogDeliveries",
      "logs:PutResourcePolicy",
      "logs:DescribeResourcePolicies",
      "logs:DescribeLogGroups",
    ]
    resources = [
      "arn:aws:logs:${local.region}:${data.aws_caller_identity.current.account_id}:log-group:*",
    ]
  }

  statement {
    sid    = "LogDeliveryWrite"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      "arn:aws:logs:${local.region}:${data.aws_caller_identity.current.account_id}:log-group:*",
    ]
  }

  statement {
    sid    = "PutLogDestination"
    effect = "Allow"
    actions = [
      "logs:PutDestination",
      "logs:PutDestinationPolicy",
    ]
    resources = [
      "arn:aws:logs:${local.region}:${data.aws_caller_identity.current.account_id}:log-group:*",
    ]
  }

  statement {
    sid    = "ADFAccess"
    effect = "Allow"
    actions = [
      "firehose:PutRecord",
      "firehose:PutRecordBatch",
    ]
    resources = [
      aws_kinesis_firehose_delivery_stream.ecs_logs_app["app-app"].arn,
      aws_kinesis_firehose_delivery_stream.ecs_logs_app["cron"].arn,
      aws_kinesis_firehose_delivery_stream.ecs_logs_app["queue"].arn,
      aws_kinesis_firehose_delivery_stream.ecs_logs_app["migrate"].arn,
      aws_kinesis_firehose_delivery_stream.ecs_logs_nginx["app-nginx"].arn,
    ]
  }

  statement {
    sid    = "GetDockerHubCredentials"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "secretsmanager:GetSecretValue",
    ]
    resources = [
      aws_kms_key.application.arn,
      "arn:aws:secretsmanager:${local.region}:${data.aws_caller_identity.current.account_id}:secret:${local.project}-${local.env}-smg-dockerhub-credentials*",
    ]
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task" {
  role       = aws_iam_role.ecs_task.name
  policy_arn = aws_iam_policy.ecs_task.arn
}

resource "aws_iam_role_policy_attachment" "ecs_task_to_ecr_read_only" {
  role       = aws_iam_role.ecs_task.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}


# ===============================================================================
# AWS IAM for Amazon Aurora
# ===============================================================================
resource "aws_iam_role" "rds_iam_auth" {
  name               = "${local.project}-${local.env}-iam-rds-iam-auth-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.rds_iam_auth_assume.json

  tags = {
    Name = "${local.project}-${local.env}-iam-rds-iam-auth-role"
  }
}

data "aws_iam_policy_document" "rds_iam_auth_assume" {
  statement {
    sid    = "RDSAssume"
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "Service"
      identifiers = [
        "rds.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_policy" "rds_iam_auth" {
  name   = "${local.project}-${local.env}-iam-rds-iam-auth-policy"
  policy = data.aws_iam_policy_document.rds_iam_auth.json

  tags = {
    Name = "${local.project}-${local.env}-iam-rds-iam-auth-policy"
  }
}

data "aws_iam_policy_document" "rds_iam_auth" {
  statement {
    sid    = "GetDatabases"
    effect = "Allow"
    actions = [
      "rds-db:connect",
      "rds-data:ExecuteStatement",
    ]
    resources = [
      "arn:aws:rds-db:${local.region}:${data.aws_caller_identity.current.account_id}:dbuser:*/*",
    ]
  }
}

resource "aws_iam_role_policy_attachment" "rds_iam_auth" {
  role       = aws_iam_role.rds_iam_auth.name
  policy_arn = aws_iam_policy.rds_iam_auth.arn
}


# ===============================================================================
# AWS IAM for Amazon Aurora Performance Insights
# ===============================================================================
resource "aws_iam_role" "rds_performance_insights" {
  name               = "${local.project}-${local.env}-iam-rds-performance-insights-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.rds_performance_insights_assume.json

  tags = {
    Name = "${local.project}-${local.env}-iam-rds-performance-insights-role"
  }
}

data "aws_iam_policy_document" "rds_performance_insights_assume" {
  statement {
    sid    = "RDSPerformanceInsightsAssume"
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "Service"
      identifiers = [
        "rds.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_policy" "rds_performance_insights" {
  name   = "${local.project}-${local.env}-iam-rds-performance-insights-policy"
  policy = data.aws_iam_policy_document.rds_performance_insights.json

  tags = {
    Name = "${local.project}-${local.env}-iam-rds-performance-insights-policy"
  }
}

data "aws_iam_policy_document" "rds_performance_insights" {
  statement {
    sid    = "GetPerformanceData"
    effect = "Allow"
    actions = [
      "rds:DescribeDBClusters",
      "rds:DescribeDBInstances",
      "rds:DescribeDBPerformanceInsights",
      "rds:GetDBPerformanceInsights",
    ]
    resources = [
      "arn:aws:rds:${local.region}:${data.aws_caller_identity.current.account_id}:db:*",
    ]
  }
}

resource "aws_iam_role_policy_attachment" "rds_performance_insights" {
  role       = aws_iam_role.rds_performance_insights.name
  policy_arn = aws_iam_policy.rds_performance_insights.arn
}


# ===============================================================================
# AWS IAM for AWS Lambda (CloudWatch Error Alert)
# ===============================================================================
resource "aws_iam_role" "lambda_cloudwatch" {
  name               = "${local.project}-${local.env}-iam-lmd-cwt-logs-error-alert-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.lambda_cloudwatch_assume.json

  tags = {
    Name = "${local.project}-${local.env}-iam-lmd-cwt-logs-error-alert-role"
  }
}

data "aws_iam_policy_document" "lambda_cloudwatch_assume" {
  statement {
    sid    = "LambdaAssume"
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_policy" "lambda_cloudwatch" {
  name   = "${local.project}-${local.env}-iam-lmd-cwt-logs-error-alert-policy"
  policy = data.aws_iam_policy_document.lambda_cloudwatch.json
  tags = {
    Name = "${local.project}-${local.env}-iam-lmd-cwt-logs-error-alert-policy"
  }
}

data "aws_iam_policy_document" "lambda_cloudwatch" {
  statement {
    sid    = "LogAccess"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      "arn:aws:logs:${local.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${local.project}-${local.env}-*:*",
    ]
  }

  statement {
    sid    = "SNSPublish"
    effect = "Allow"
    actions = [
      "sns:Publish",
    ]
    resources = [
      aws_sns_topic.event_alarm.arn,
    ]
  }

  statement {
    sid    = "ADFAccess"
    effect = "Allow"
    actions = [
      "firehose:PutRecord",
      "firehose:PutRecordBatch",
    ]
    resources = [
      aws_kinesis_firehose_delivery_stream.lambda_logs[aws_lambda_function.lambda_log_error_alert.function_name].arn,
      aws_kinesis_firehose_delivery_stream.lambda_logs[aws_lambda_function.lambda_metric_alarm.function_name].arn,
      aws_kinesis_firehose_delivery_stream.lambda_logs[aws_lambda_function.rds_control.function_name].arn,
      aws_kinesis_firehose_delivery_stream.lambda_logs[aws_lambda_function.lambda_schedule_ecs_maintenance.function_name].arn,
      aws_kinesis_firehose_delivery_stream.lambda_logs[aws_lambda_function.lambda_execute_ecs_force_deployment.function_name].arn,
    ]
  }
}

resource "aws_iam_role_policy_attachment" "lambda_cloudwatch" {
  role       = aws_iam_role.lambda_cloudwatch.name
  policy_arn = aws_iam_policy.lambda_cloudwatch.arn
}


# ===============================================================================
# AWS IAM for AWS Lambda (RDS Control)
# ===============================================================================
resource "aws_iam_role" "rds_control" {
  name               = "${local.project}-${local.env}-iam-lmd-rds-control-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.rds_control_assume.json

  tags = {
    Name = "${local.project}-${local.env}-iam-lmd-rds-control-role"
  }
}

data "aws_iam_policy_document" "rds_control_assume" {
  statement {
    sid    = "LambdaAssume"
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_policy" "rds_control" {
  name   = "${local.project}-${local.env}-iam-lmd-rds-control-policy"
  policy = data.aws_iam_policy_document.rds_control.json

  tags = {
    Name = "${local.project}-${local.env}-iam-lmd-rds-control-policy"
  }
}

data "aws_iam_policy_document" "rds_control" {
  statement {
    sid    = "LogsAccess"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      "arn:aws:logs:${local.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${local.project}-${local.env}-*:*",
    ]
  }

  statement {
    sid    = "RDSAccess"
    effect = "Allow"
    actions = [
      "rds:DescribeDBClusters",
      "rds:DescribeDBInstances",
      "rds:StartDBCluster",
      "rds:StopDBCluster",
      "rds:ListTagsForResource",
    ]
    resources = [
      "arn:aws:rds:${local.region}:${data.aws_caller_identity.current.account_id}:cluster:*",
      "arn:aws:rds:${local.region}:${data.aws_caller_identity.current.account_id}:db:*",
    ]
  }

  statement {
    sid    = "SNSPublish"
    effect = "Allow"
    actions = [
      "sns:Publish",
    ]
    resources = [
      aws_sns_topic.event_alarm.arn,
    ]
  }

  statement {
    sid    = "ADFAccess"
    effect = "Allow"
    actions = [
      "firehose:PutRecord",
      "firehose:PutRecordBatch",
    ]
    resources = [
      aws_kinesis_firehose_delivery_stream.lambda_logs[aws_lambda_function.lambda_log_error_alert.function_name].arn,
      aws_kinesis_firehose_delivery_stream.lambda_logs[aws_lambda_function.lambda_metric_alarm.function_name].arn,
      aws_kinesis_firehose_delivery_stream.lambda_logs[aws_lambda_function.rds_control.function_name].arn,
      aws_kinesis_firehose_delivery_stream.lambda_logs[aws_lambda_function.lambda_schedule_ecs_maintenance.function_name].arn,
      aws_kinesis_firehose_delivery_stream.lambda_logs[aws_lambda_function.lambda_execute_ecs_force_deployment.function_name].arn,
    ]
  }
}

resource "aws_iam_role_policy_attachment" "rds_control" {
  role       = aws_iam_role.rds_control.name
  policy_arn = aws_iam_policy.rds_control.arn
}


# ===============================================================================
# AWS IAM for AWS Lambda (Schedule ECS Maintenance Handler)
# ===============================================================================
resource "aws_iam_role" "lambda_schedule_ecs_maintenance" {
  name               = "${local.project}-${local.env}-iam-schedule-ecs-maintenance-handler-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.lambda_schedule_ecs_maintenance_assume.json

  tags = {
    Name = "${local.project}-${local.env}-iam-lmd-schedule-ecs-maintenance-handler-role"
  }
}

data "aws_iam_policy_document" "lambda_schedule_ecs_maintenance_assume" {
  statement {
    sid    = "LambdaAssume"
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_policy" "lambda_schedule_ecs_maintenance" {
  name   = "${local.project}-${local.env}-iam-lmd-schedule-ecs-maintenance-handler-policy"
  policy = data.aws_iam_policy_document.lambda_schedule_ecs_maintenance.json

  tags = {
    Name = "${local.project}-${local.env}-iam-lmd-schedule-ecs-maintenance-handler-policy"
  }
}

data "aws_iam_policy_document" "lambda_schedule_ecs_maintenance" {
  statement {
    sid    = "LogAccess"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      "arn:aws:logs:${local.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/*:*",
    ]
  }

  # Retrieve cluster name and service name from ECS task name.
  statement {
    sid    = "AllowECSDescribeTasks"
    effect = "Allow"
    actions = [
      "ecs:DescribeTasks",
    ]
    resources = [
      "*",
    ]
  }

  # Create an EventBridge scheduler.
  statement {
    sid    = "AllowCreateSchedule"
    effect = "Allow"
    actions = [
      "scheduler:CreateSchedule",
    ]
    resources = [
      "*",
    ]
  }

  # Pass Role to pass an IAM role to the EventBridge scheduler when creating a schedule.
  statement {
    sid    = "AllowPassRoleToScheduler"
    effect = "Allow"
    actions = [
      "iam:PassRole",
    ]
    resources = [
      aws_iam_role.eventbridge_scheduler_maintenance_ecs.arn,
    ]
    condition {
      test     = "StringLike"
      variable = "iam:PassedToService"
      values = [
        "scheduler.amazonaws.com",
      ]
    }
  }

  statement {
    sid    = "SNSPublish"
    effect = "Allow"
    actions = [
      "sns:Publish",
    ]
    resources = [
      aws_sns_topic.event_alarm.arn,
    ]
  }

  statement {
    sid    = "ADFAccess"
    effect = "Allow"
    actions = [
      "firehose:PutRecord",
      "firehose:PutRecordBatch",
    ]
    resources = [
      aws_kinesis_firehose_delivery_stream.lambda_logs[aws_lambda_function.lambda_log_error_alert.function_name].arn,
      aws_kinesis_firehose_delivery_stream.lambda_logs[aws_lambda_function.lambda_metric_alarm.function_name].arn,
      aws_kinesis_firehose_delivery_stream.lambda_logs[aws_lambda_function.rds_control.function_name].arn,
      aws_kinesis_firehose_delivery_stream.lambda_logs[aws_lambda_function.lambda_schedule_ecs_maintenance.function_name].arn,
      aws_kinesis_firehose_delivery_stream.lambda_logs[aws_lambda_function.lambda_execute_ecs_force_deployment.function_name].arn,
    ]
  }
}

resource "aws_iam_role_policy_attachment" "lambda_schedule_ecs_maintenance" {
  role       = aws_iam_role.lambda_schedule_ecs_maintenance.name
  policy_arn = aws_iam_policy.lambda_schedule_ecs_maintenance.arn
}


# ===============================================================================
# AWS IAM for AWS Lambda (Execute ECS Force Deployment)
# ===============================================================================
resource "aws_iam_role" "lambda_execute_ecs_force_deployment" {
  name               = "${local.project}-${local.env}-iam-execute-ecs-force-deployment-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.lambda_execute_ecs_force_deployment_assume.json

  tags = {
    Name = "${local.project}-${local.env}-iam-lmd-execute-ecs-force-deployment-role"
  }
}

data "aws_iam_policy_document" "lambda_execute_ecs_force_deployment_assume" {
  statement {
    sid    = "LambdaAssume"
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_policy" "lambda_execute_ecs_force_deployment" {
  name   = "${local.project}-${local.env}-iam-lmd-execute-ecs-force-deployment-policy"
  policy = data.aws_iam_policy_document.lambda_execute_ecs_force_deployment.json

  tags = {
    Name = "${local.project}-${local.env}-iam-lmd-execute-ecs-force-deployment-policy"
  }
}

data "aws_iam_policy_document" "lambda_execute_ecs_force_deployment" {
  statement {
    sid    = "LogAccess"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      "arn:aws:logs:${local.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/*:*",
    ]
  }

  # Perform rolling updates on ECS services to apply new task definitions.
  statement {
    sid    = "AllowECSUpdateService"
    effect = "Allow"
    actions = [
      "ecs:UpdateService",
    ]
    resources = [
      aws_ecs_service.app.arn,
      aws_ecs_service.cron.arn,
      aws_ecs_service.queue.arn,
    ]
  }

  statement {
    sid    = "SNSPublish"
    effect = "Allow"
    actions = [
      "sns:Publish",
    ]
    resources = [
      aws_sns_topic.event_alarm.arn,
    ]
  }

  statement {
    sid    = "ADFAccess"
    effect = "Allow"
    actions = [
      "firehose:PutRecord",
      "firehose:PutRecordBatch",
    ]
    resources = [
      aws_kinesis_firehose_delivery_stream.lambda_logs[aws_lambda_function.lambda_log_error_alert.function_name].arn,
      aws_kinesis_firehose_delivery_stream.lambda_logs[aws_lambda_function.lambda_metric_alarm.function_name].arn,
      aws_kinesis_firehose_delivery_stream.lambda_logs[aws_lambda_function.rds_control.function_name].arn,
      aws_kinesis_firehose_delivery_stream.lambda_logs[aws_lambda_function.lambda_schedule_ecs_maintenance.function_name].arn,
      aws_kinesis_firehose_delivery_stream.lambda_logs[aws_lambda_function.lambda_execute_ecs_force_deployment.function_name].arn,
    ]
  }
}

resource "aws_iam_role_policy_attachment" "lambda_execute_ecs_force_deployment" {
  role       = aws_iam_role.lambda_execute_ecs_force_deployment.name
  policy_arn = aws_iam_policy.lambda_execute_ecs_force_deployment.arn
}


# ===============================================================================
# AWS IAM for Amazon EventBridge Scheduler (EventBridge Scheduler Maintenance ECS)
# ===============================================================================
resource "aws_iam_role" "eventbridge_scheduler_maintenance_ecs" {
  name               = "${local.project}-${local.env}-iam-ebd-scheduler-maintenance-ecs-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.eventbridge_scheduler_maintenance_ecs_assume.json

  tags = {
    Name = "${local.project}-${local.env}-iam-ebd-scheduler-maintenance-ecs-role"
  }
}

data "aws_iam_policy_document" "eventbridge_scheduler_maintenance_ecs_assume" {
  statement {
    sid    = "EventBridgeSchedulerAssume"
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "Service"
      identifiers = [
        "scheduler.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_policy" "eventbridge_scheduler_maintenance_ecs" {
  name   = "${local.project}-${local.env}-iam-ebd-scheduler-maintenance-ecs-policy"
  policy = data.aws_iam_policy_document.eventbridge_scheduler_maintenance_ecs.json

  tags = {
    Name = "${local.project}-${local.env}-iam-ebd-scheduler-maintenance-ecs-policy"
  }
}

data "aws_iam_policy_document" "eventbridge_scheduler_maintenance_ecs" {
  statement {
    sid    = "AllowInvokeLambda"
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction",
    ]
    resources = [
      aws_lambda_function.lambda_execute_ecs_force_deployment.arn,
    ]
  }

  statement {
    sid    = "SNSPublish"
    effect = "Allow"
    actions = [
      "sns:Publish",
    ]
    resources = [
      aws_sns_topic.event_alarm.arn,
    ]
  }

  statement {
    sid    = "ADFAccess"
    effect = "Allow"
    actions = [
      "firehose:PutRecord",
      "firehose:PutRecordBatch",
    ]
    resources = [
      aws_kinesis_firehose_delivery_stream.lambda_logs[aws_lambda_function.lambda_log_error_alert.function_name].arn,
      aws_kinesis_firehose_delivery_stream.lambda_logs[aws_lambda_function.lambda_metric_alarm.function_name].arn,
      aws_kinesis_firehose_delivery_stream.lambda_logs[aws_lambda_function.rds_control.function_name].arn,
      aws_kinesis_firehose_delivery_stream.lambda_logs[aws_lambda_function.lambda_schedule_ecs_maintenance.function_name].arn,
      aws_kinesis_firehose_delivery_stream.lambda_logs[aws_lambda_function.lambda_execute_ecs_force_deployment.function_name].arn,
    ]
  }
}

resource "aws_iam_role_policy_attachment" "eventbridge_scheduler_maintenance_ecs" {
  role       = aws_iam_role.eventbridge_scheduler_maintenance_ecs.name
  policy_arn = aws_iam_policy.eventbridge_scheduler_maintenance_ecs.arn
}


# ===============================================================================
# AWS IAM for Amazon Data Firehose
# ===============================================================================
resource "aws_iam_role" "amazon_data_firehose" {
  name               = "${local.project}-${local.env}-iam-adf-role"
  assume_role_policy = data.aws_iam_policy_document.amazon_data_firehose_assume.json

  tags = {
    Name = "${local.project}-${local.env}-iam-adf-role"
  }
}

data "aws_iam_policy_document" "amazon_data_firehose_assume" {
  statement {
    sid    = "ADFAssume"
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "Service"
      identifiers = [
        "firehose.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_policy" "amazon_data_firehose" {
  name   = "${local.project}-${local.env}-iam-adf-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.amazon_data_firehose.json

  tags = {
    Name = "${local.project}-${local.env}-iam-adf-policy"
  }
}

data "aws_iam_policy_document" "amazon_data_firehose" {
  statement {
    sid    = "S3Access"
    effect = "Allow"
    actions = [
      "s3:ListAllMyBuckets",
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = [
      aws_s3_bucket.ses_event_logs.arn,
      "${aws_s3_bucket.ses_event_logs.arn}/*",
      aws_s3_bucket.sns_event_logs.arn,
      "${aws_s3_bucket.sns_event_logs.arn}/*",
      aws_s3_bucket.ecs_logs.arn,
      "${aws_s3_bucket.ecs_logs.arn}/*",
      aws_s3_bucket.aurora_logs.arn,
      "${aws_s3_bucket.aurora_logs.arn}/*",
      aws_s3_bucket.elasticache_logs.arn,
      "${aws_s3_bucket.elasticache_logs.arn}/*",
      aws_s3_bucket.lambda_logs.arn,
      "${aws_s3_bucket.lambda_logs.arn}/*",
      aws_s3_bucket.ses_logs.arn,
      "${aws_s3_bucket.ses_logs.arn}/*",
      aws_s3_bucket.sns_logs.arn,
      "${aws_s3_bucket.sns_logs.arn}/*",
      aws_s3_bucket.bastion.arn,
      "${aws_s3_bucket.bastion.arn}/*",
    ]
  }

  statement {
    sid    = "PutLogEvents"
    effect = "Allow"
    actions = [
      "logs:PutLogEvents",
    ]
    resources = [
      aws_cloudwatch_log_stream.fargate_app["app-app"].arn,
      "${aws_cloudwatch_log_stream.fargate_app["app-app"].arn}:*",
      aws_cloudwatch_log_stream.fargate_app["cron"].arn,
      "${aws_cloudwatch_log_stream.fargate_app["cron"].arn}:*",
      aws_cloudwatch_log_stream.fargate_app["queue"].arn,
      "${aws_cloudwatch_log_stream.fargate_app["queue"].arn}:*",
      aws_cloudwatch_log_stream.fargate_app["migrate"].arn,
      "${aws_cloudwatch_log_stream.fargate_app["migrate"].arn}:*",
      aws_cloudwatch_log_stream.fargate_nginx["app-nginx"].arn,
      "${aws_cloudwatch_log_stream.fargate_nginx["app-nginx"].arn}:*",
      aws_cloudwatch_log_stream.rds["audit"].arn,
      "${aws_cloudwatch_log_stream.rds["audit"].arn}:*",
      aws_cloudwatch_log_stream.rds["error"].arn,
      "${aws_cloudwatch_log_stream.rds["error"].arn}:*",
      aws_cloudwatch_log_stream.rds["general"].arn,
      "${aws_cloudwatch_log_stream.rds["general"].arn}:*",
      aws_cloudwatch_log_stream.rds["slowquery"].arn,
      "${aws_cloudwatch_log_stream.rds["slowquery"].arn}:*",
      aws_cloudwatch_log_stream.elasticache.arn,
      "${aws_cloudwatch_log_stream.elasticache.arn}:*",
      aws_cloudwatch_log_stream.lambda_functions[aws_lambda_function.lambda_log_error_alert.function_name].arn,
      "${aws_cloudwatch_log_stream.lambda_functions[aws_lambda_function.lambda_log_error_alert.function_name].arn}:*",
      aws_cloudwatch_log_stream.lambda_functions[aws_lambda_function.lambda_metric_alarm.function_name].arn,
      "${aws_cloudwatch_log_stream.lambda_functions[aws_lambda_function.lambda_metric_alarm.function_name].arn}:*",
      aws_cloudwatch_log_stream.lambda_functions[aws_lambda_function.rds_control.function_name].arn,
      "${aws_cloudwatch_log_stream.lambda_functions[aws_lambda_function.rds_control.function_name].arn}:*",
      aws_cloudwatch_log_stream.lambda_functions[aws_lambda_function.lambda_schedule_ecs_maintenance.function_name].arn,
      "${aws_cloudwatch_log_stream.lambda_functions[aws_lambda_function.lambda_schedule_ecs_maintenance.function_name].arn}:*",
      aws_cloudwatch_log_stream.lambda_functions[aws_lambda_function.lambda_execute_ecs_force_deployment.function_name].arn,
      "${aws_cloudwatch_log_stream.lambda_functions[aws_lambda_function.lambda_execute_ecs_force_deployment.function_name].arn}:*",
      aws_cloudwatch_log_stream.ses.arn,
      "${aws_cloudwatch_log_stream.ses.arn}:*",
      aws_cloudwatch_log_stream.sns.arn,
      "${aws_cloudwatch_log_stream.sns.arn}:*",
      aws_cloudwatch_log_stream.adf.arn,
      "${aws_cloudwatch_log_stream.adf.arn}:*",
      aws_cloudwatch_log_stream.bastion.arn,
      "${aws_cloudwatch_log_stream.bastion.arn}:*",
    ]
  }
}

resource "aws_iam_role_policy_attachment" "amazon_data_firehose" {
  role       = aws_iam_role.amazon_data_firehose.name
  policy_arn = aws_iam_policy.amazon_data_firehose.arn
}


# ===============================================================================
# AWS IAM for Amazon SES
# ===============================================================================
resource "aws_iam_role" "ses" {
  name               = "${local.project}-${local.env}-iam-ses-role"
  assume_role_policy = data.aws_iam_policy_document.ses_assume.json

  tags = {
    Name = "${local.project}-${local.env}-iam-ses-role"
  }
}

data "aws_iam_policy_document" "ses_assume" {
  statement {
    sid    = "SESAssume"
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "Service"
      identifiers = [
        "ses.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_policy" "ses" {
  name   = "${local.project}-${local.env}-iam-ses-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.ses.json

  tags = {
    Name = "${local.project}-${local.env}-iam-ses-policy"
  }
}

data "aws_iam_policy_document" "ses" {
  statement {
    sid    = "ADFAccess"
    effect = "Allow"
    actions = [
      "firehose:PutRecord",
      "firehose:PutRecordBatch",
    ]
    resources = [
      aws_kinesis_firehose_delivery_stream.ses_logs.arn,
      aws_kinesis_firehose_delivery_stream.ses_event_logs.arn,
    ]
  }
}

resource "aws_iam_role_policy_attachment" "ses" {
  role       = aws_iam_role.ses.name
  policy_arn = aws_iam_policy.ses.arn
}


# ===============================================================================
# AWS IAM for Amazon SNS
# ===============================================================================
resource "aws_iam_role" "sns" {
  name               = "${local.project}-${local.env}-iam-sns-role"
  assume_role_policy = data.aws_iam_policy_document.sns_assume.json

  tags = {
    Name = "${local.project}-${local.env}-iam-sns-role"
  }
}

data "aws_iam_policy_document" "sns_assume" {
  statement {
    sid    = "SNSAssume"
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "Service"
      identifiers = [
        "sns.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_policy" "sns" {
  name   = "${local.project}-${local.env}-iam-sns-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.sns.json

  tags = {
    Name = "${local.project}-${local.env}-iam-sns-policy"
  }
}

data "aws_iam_policy_document" "sns" {
  statement {
    sid    = "DescribeLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      aws_cloudwatch_log_group.sns.arn,
    ]
  }

  statement {
    sid    = "SNSSubscribe"
    effect = "Allow"
    actions = [
      "sns:Subscribe",
    ]
    resources = [
      aws_sns_topic.metric_alarm.arn,
      aws_sns_topic.event_alarm.arn,
      aws_sns_topic.inspector_notifications.arn,
      aws_sns_topic.event_notifications.arn,
    ]
  }

  statement {
    sid    = "ADFAccess"
    effect = "Allow"
    actions = [
      "firehose:PutRecord",
      "firehose:PutRecordBatch",
    ]
    resources = [
      aws_kinesis_firehose_delivery_stream.sns_logs.arn,
    ]
  }
}

resource "aws_iam_role_policy_attachment" "sns" {
  role       = aws_iam_role.sns.name
  policy_arn = aws_iam_policy.sns.arn
}


# ===============================================================================
# AWS IAM for Amazon Inspector
# ===============================================================================
resource "aws_iam_role" "inspector" {
  name               = "${local.project}-${local.env}-iam-inspector-role"
  assume_role_policy = data.aws_iam_policy_document.inspector_assume.json

  tags = {
    Name = "${local.project}-${local.env}-iam-inspector-role"
  }
}

data "aws_iam_policy_document" "inspector_assume" {
  statement {
    sid    = "EventAssume"
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_policy" "inspector" {
  name   = "${local.project}-${local.env}-iam-inspector-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.inspector.json

  tags = {
    Name = "${local.project}-${local.env}-iam-inspector-policy"
  }
}

data "aws_iam_policy_document" "inspector" {
  statement {
    sid    = "InspectorAccess"
    effect = "Allow"
    actions = [
      "inspector:StartAssessmentRun",
    ]
    resources = [
      aws_ecr_repository.nginx_base.arn,
      aws_ecr_repository.app_base.arn,
      aws_ecr_repository.nginx.arn,
      aws_ecr_repository.app.arn,
      aws_lambda_function.lambda_log_error_alert.arn,
      aws_lambda_function.lambda_metric_alarm.arn,
      aws_lambda_function.rds_control.arn,
      aws_lambda_function.lambda_schedule_ecs_maintenance.arn,
      aws_lambda_function.lambda_execute_ecs_force_deployment.arn,
    ]
  }

  statement {
    sid    = "SNSPublish"
    effect = "Allow"
    actions = [
      "sns:Publish",
    ]
    resources = [
      aws_sns_topic.event_alarm.arn,
    ]
  }
}

resource "aws_iam_role_policy_attachment" "inspector" {
  role       = aws_iam_role.inspector.name
  policy_arn = aws_iam_policy.inspector.arn
}


# ===============================================================================
# AWS IAM for AWS Chatbot
# ===============================================================================
resource "aws_iam_role" "chatbot" {
  name               = "${local.project}-${local.env}-iam-chatbot-role"
  assume_role_policy = data.aws_iam_policy_document.chatbot_assume.json

  tags = {
    Name = "${local.project}-${local.env}-iam-chatbot-role"
  }
}

data "aws_iam_policy_document" "chatbot_assume" {
  statement {
    sid    = "ChatbotAssume"
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "Service"
      identifiers = [
        "chatbot.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_policy" "chatbot" {
  name   = "${local.project}-${local.env}-iam-chatbot-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.chatbot.json

  tags = {
    Name = "${local.project}-${local.env}-iam-chatbot-policy"
  }
}

data "aws_iam_policy_document" "chatbot" {
  statement {
    sid    = "SNSAccess"
    effect = "Allow"
    actions = [
      "sns:GetTopicAttributes",
      "sns:SetTopicAttributes",
      "sns:AddPermission",
      "sns:RemovePermission",
      "sns:DeleteTopic",
      "sns:Subscribe",
      "sns:Unsubscribe",
      "sns:ListTopics",
      "sns:ListSubscriptions",
      "sns:ListSubscriptionsByTopic",
      "sns:Publish",
    ]
    resources = [
      aws_sns_topic.metric_alarm.arn,
      aws_sns_topic.event_alarm.arn,
      aws_sns_topic.inspector_notifications.arn,
      aws_sns_topic.event_notifications.arn,
    ]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"
      values = [
        data.aws_caller_identity.current.account_id,
      ]
    }
  }

  statement {
    sid    = "SNSPublish"
    effect = "Allow"
    actions = [
      "sns:Publish",
      "sns:Subscribe",
    ]
    resources = [
      aws_sns_topic.metric_alarm.arn,
      aws_sns_topic.event_alarm.arn,
      aws_sns_topic.inspector_notifications.arn,
      aws_sns_topic.event_notifications.arn,
    ]
  }

  statement {
    sid    = "LogAccess"
    effect = "Allow"
    actions = [
      "logs:PutLogEvents",
      "logs:CreateLogStream",
      "logs:DescribeLogStreams",
      "logs:CreateLogGroup",
      "logs:DescribeLogGroups",
    ]
    resources = [
      "arn:aws:logs:*:*:log-group:/aws/chatbot/*",
    ]
  }

  statement {
    sid    = "ChatbotAccess"
    effect = "Allow"
    actions = [
      "chatbot:CreateSlackChannelConfiguration",
      "chatbot:DescribeSlackChannelConfigurations",
      "chatbot:DeleteSlackChannelConfiguration",
      "chatbot:UpdateSlackChannelConfiguration",
    ]
    resources = [
      "arn:aws:chatbot::${data.aws_caller_identity.current.account_id}:chat-configuration/slack-channel/*",
    ]
  }
}

resource "aws_iam_role_policy_attachment" "chatbot" {
  role       = aws_iam_role.chatbot.name
  policy_arn = aws_iam_policy.chatbot.arn
}

resource "aws_iam_role_policy_attachment" "chatbot_resource_read_only_access" {
  role       = aws_iam_role.chatbot.name
  policy_arn = "arn:aws:iam::aws:policy/AWSResourceExplorerReadOnlyAccess"
}


# ===============================================================================
# AWS IAM for AWS Chatbot Guardrail
# ===============================================================================
resource "aws_iam_policy" "chatbot_guardrail" {
  name   = "${local.project}-${local.env}-iam-chatbot-guardrail-policy"
  policy = data.aws_iam_policy_document.chatbot_guardrail.json

  tags = {
    Name = "${local.project}-${local.env}-iam-chatbot-guardrail-policy"
  }
}

data "aws_iam_policy_document" "chatbot_guardrail" {
  statement {
    sid    = "ChatbotAccess"
    effect = "Allow"
    actions = [
      "chatbot:DescribeSlackChannelConfigurations",
    ]
    resources = [
      "arn:aws:chatbot::${data.aws_caller_identity.current.account_id}:chat-configuration/slack-channel/*",
    ]
  }
}


# ===============================================================================
# AWS IAM for Amazon EventBridge Scheduler
# ===============================================================================
resource "aws_iam_role" "event_bridge_scheduler" {
  name               = "${local.project}-${local.env}-iam-ebd-scheduler-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.event_bridge_scheduler_assume.json

  tags = {
    Name = "${local.project}-${local.env}-iam-ebd-scheduler-role"
  }
}

data "aws_iam_policy_document" "event_bridge_scheduler_assume" {
  statement {
    sid    = "SchedulerAssume"
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "Service"
      identifiers = [
        "scheduler.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_policy" "event_bridge_scheduler" {
  name   = "${local.project}-${local.env}-iam-ebd-scheduler-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.event_bridge_scheduler.json

  tags = {
    Name = "${local.project}-${local.env}-iam-ebd-scheduler-policy"
  }
}

data "aws_iam_policy_document" "event_bridge_scheduler" {
  statement {
    sid    = "ControlRDS"
    effect = "Allow"
    actions = [
      "rds:DescribeDBClusters",
      "rds:DescribeDBInstances",
      "rds:StartDBCluster",
      "rds:StopDBCluster",
    ]
    resources = [
      "arn:aws:rds:${local.region}:${data.aws_caller_identity.current.account_id}:cluster:${local.project}-${local.env}-aurora-cluster",
      "arn:aws:rds:${local.region}:${data.aws_caller_identity.current.account_id}:db:${local.project}-${local.env}-aurora-instance-*",
    ]
  }
}

resource "aws_iam_role_policy_attachment" "event_bridge_scheduler" {
  role       = aws_iam_role.event_bridge_scheduler.name
  policy_arn = aws_iam_policy.event_bridge_scheduler.arn
}


# ===============================================================================
# AWS IAM for Amazon CloudWatch Logs to Amazon Data Firehose
# ===============================================================================
resource "aws_iam_role" "cloudwatch_logs_to_amazon_data_firehose" {
  name               = "${local.project}-${local.env}-iam-cwt-logs-to-adf-role"
  assume_role_policy = data.aws_iam_policy_document.cloudwatch_logs_to_amazon_data_firehose_assume.json

  tags = {
    Name = "${local.project}-${local.env}-iam-cwt-logs-to-adf-role"
  }
}

data "aws_iam_policy_document" "cloudwatch_logs_to_amazon_data_firehose_assume" {
  statement {
    sid    = "CloudWatchLogsAndADFAssume"
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "Service"
      identifiers = [
        "firehose.amazonaws.com",
        "logs.${local.region}.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_policy" "cloudwatch_logs_to_amazon_data_firehose" {
  name   = "${local.project}-${local.env}-iam-cwt-logs-to-adf-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.cloudwatch_logs_to_amazon_data_firehose.json

  tags = {
    Name = "${local.project}-${local.env}-iam-cwt-logs-to-adf-policy"
  }
}

data "aws_iam_policy_document" "cloudwatch_logs_to_amazon_data_firehose" {
  statement {
    sid    = "ADFAccess"
    effect = "Allow"
    actions = [
      "firehose:PutRecord",
      "firehose:PutRecordBatch",
    ]
    resources = [
      "arn:aws:firehose:${local.region}:${data.aws_caller_identity.current.account_id}:deliverystream/*",
    ]
  }

  statement {
    sid    = "CloudWatchLogsAccess"
    effect = "Allow"
    actions = [
      "logs:PutLogEvents",
      "logs:CreateLogStream",
      "logs:DescribeLogStreams",
      "logs:CreateLogGroup",
      "logs:DescribeLogGroups",
    ]
    resources = concat(
      [for key in local.fargate_app_cloudwatch_log_group : aws_cloudwatch_log_group.fargate_app[key].arn],
      [for key in local.fargate_nginx_cloudwatch_log_group : aws_cloudwatch_log_group.fargate_nginx[key].arn],
      [for key in local.aurora_cloudwatch_log_group : aws_cloudwatch_log_group.rds[key].arn],
      [aws_cloudwatch_log_group.elasticache.arn],
      [for key in local.lambda_functions : aws_cloudwatch_log_group.lambda_functions[key].arn],
      [aws_cloudwatch_log_group.ses.arn],
      [aws_cloudwatch_log_group.sns.arn],
      [aws_cloudwatch_log_group.adf.arn],
      [aws_cloudwatch_log_group.bastion.arn],
    )
  }
}

resource "aws_iam_role_policy_attachment" "cloudwatch_logs_to_amazon_data_firehose" {
  role       = aws_iam_role.cloudwatch_logs_to_amazon_data_firehose.name
  policy_arn = aws_iam_policy.cloudwatch_logs_to_amazon_data_firehose.arn
}


# ================================================================================
# Amazon EC2 Instance Profile for Bastion
# ================================================================================
resource "aws_iam_instance_profile" "bastion" {
  name = "${local.project}-${local.env}-iam-ec2-bastion-profile"
  role = aws_iam_role.bastion.name
}

resource "aws_iam_role" "bastion" {
  name               = "${local.project}-${local.env}-iam-ec2-bastion-role"
  assume_role_policy = data.aws_iam_policy_document.bastion_assume.json

  tags = {
    Name = "${local.project}-${local.env}-iam-ec2-bastion-role"
  }
}

data "aws_iam_policy_document" "bastion_assume" {
  statement {
    sid    = "EC2Assume"
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "Service"
      identifiers = [
        "ec2.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_policy" "bastion" {
  name   = "${local.project}-${local.env}-iam-ec2-bastion-policy"
  policy = data.aws_iam_policy_document.bastion.json

  tags = {
    Name = "${local.project}-${local.env}-iam-ec2-bastion-policy"
  }
}

data "aws_iam_policy_document" "bastion" {
  statement {
    sid    = "GetConfigFromS3"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
    ]
    resources = [
      "${aws_s3_bucket.bastion.arn}/*",
    ]
  }

  statement {
    sid    = "S3Access"
    effect = "Allow"
    actions = [
      "s3:ListAllMyBuckets",
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
    ]
    resources = [
      "arn:aws:s3:::*",
    ]
  }

  statement {
    sid    = "LogAccess"
    effect = "Allow"
    actions = [
      "logs:PutLogEvents",
      "logs:CreateLogStream",
      "logs:DescribeLogStreams",
      "logs:CreateLogGroup",
      "logs:DescribeLogGroups",
    ]
    resources = [
      aws_cloudwatch_log_group.bastion.arn,
      "${aws_cloudwatch_log_group.bastion.arn}:log-stream:*",
    ]
  }

  statement {
    sid    = "PutMetricData"
    effect = "Allow"
    actions = [
      "cloudwatch:PutMetricData",
    ]
    resources = [
      aws_cloudwatch_metric_alarm.ec2_bastion_cpu_high.arn,
      aws_cloudwatch_metric_alarm.ec2_bastion_memory_high.arn,
      aws_cloudwatch_metric_alarm.ec2_bastion_disk_high.arn,
      aws_cloudwatch_metric_alarm.ec2_bastion_status_check_failed.arn,
    ]
  }
}

resource "aws_iam_role_policy_attachment" "bastion" {
  role       = aws_iam_role.bastion.name
  policy_arn = aws_iam_policy.bastion.arn
}

resource "aws_iam_role_policy_attachment" "bastion_to_ssm" {
  role       = aws_iam_role.bastion.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


# ================================================================================
# AWS IAM for Login SSH to Bastion
# ================================================================================
resource "aws_iam_policy" "ssh_login" {
  name   = "${local.project}-${local.env}-iam-ssh-login-policy"
  policy = data.aws_iam_policy_document.ssh_login.json

  tags = {
    Name = "${local.project}-${local.env}-iam-ssh-login-policy"
  }
}

data "aws_iam_policy_document" "ssh_login" {
  statement {
    sid    = "AssumeLogin"
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/mcury-web-mnt-iam-ssh-role",
    ]
  }

  statement {
    sid    = "EC2DescribeTags"
    effect = "Allow"
    actions = [
      "ec2:DescribeTags",
    ]
    resources = [
      "*",
    ]
  }
}

resource "aws_iam_role_policy_attachment" "ssh_login" {
  role       = aws_iam_role.bastion.name
  policy_arn = aws_iam_policy.ssh_login.arn
}


# ===============================================================================
# AWS IAM for AWS Data Lifecycle Manager
# Reference: https://docs.aws.amazon.com/ja_jp/ebs/latest/userguide/dlm-prerequisites.html
# Reference: https://docs.aws.amazon.com/ja_jp/ebs/latest/userguide/managed-policies.html
# ===============================================================================
resource "aws_iam_role" "dlm" {
  name               = "${local.project}-${local.env}-iam-dlm-role"
  assume_role_policy = data.aws_iam_policy_document.dlm_assume.json

  tags = {
    Name = "${local.project}-${local.env}-iam-dlm-role"
  }
}

data "aws_iam_policy_document" "dlm_assume" {
  statement {
    sid    = "DLMAssume"
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "Service"
      identifiers = [
        "dlm.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_policy" "dlm" {
  name   = "${local.project}-${local.env}-iam-dlm-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.dlm.json

  tags = {
    Name = "${local.project}-${local.env}-iam-dlm-policy"
  }
}

data "aws_iam_policy_document" "dlm" {
  statement {
    sid    = "DLMFullAccess"
    effect = "Allow"
    actions = [
      "dlm:*",
    ]
    resources = [
      "*",
    ]
  }

  statement {
    sid    = "AllowPassRole"
    effect = "Allow"
    actions = [
      "iam:PassRole",
    ]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/AWSDataLifecycleManagerDefaultRole",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/AWSDataLifecycleManagerDefaultRoleForAMIManagement",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/service-role/AWSDataLifecycleManagerDefaultRole",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/service-role/AWSDataLifecycleManagerDefaultRoleForAMIManagement",
    ]
  }

  statement {
    sid    = "AllowListRoles"
    effect = "Allow"
    actions = [
      "iam:ListRoles",
    ]
    resources = [
      "*",
    ]
  }

  statement {
    sid    = "ControlVolumesAndSnapshots"
    effect = "Allow"
    actions = [
      "ec2:CreateSnapshot",
      "ec2:CreateSnapshots",
      "ec2:DeleteSnapshot",
      "ec2:DescribeInstances",
      "ec2:DescribeVolumes",
      "ec2:DescribeSnapshots",
      "ec2:EnableFastSnapshotRestores",
      "ec2:DescribeFastSnapshotRestores",
      "ec2:DisableFastSnapshotRestores",
      "ec2:CopySnapshot",
      "ec2:ModifySnapshotAttribute",
      "ec2:DescribeSnapshotAttribute",
      "ec2:ModifySnapshotTier",
      "ec2:DescribeSnapshotTierStatus",
      "ec2:DescribeRegions",
      "ec2:DescribeAvailabilityZones",
      "kms:DescribeKey",
      "kms:ListAliases",
    ]
    resources = [
      "*",
    ]
  }

  statement {
    sid    = "CreateTags"
    effect = "Allow"
    actions = [
      "ec2:CreateTags",
    ]
    resources = [
      "arn:aws:ec2:*::snapshot/*",
    ]
  }

  statement {
    sid    = "ControlEventRules"
    effect = "Allow"
    actions = [
      "events:PutRule",
      "events:DeleteRule",
      "events:DescribeRule",
      "events:EnableRule",
      "events:DisableRule",
      "events:ListTargetsByRule",
      "events:PutTargets",
      "events:RemoveTargets",
    ]
    resources = [
      "arn:aws:events:*:*:rule/AwsDataLifecycleRule.managed-cwe.*",
    ]
  }
}

resource "aws_iam_role_policy_attachment" "dlm" {
  role       = aws_iam_role.dlm.name
  policy_arn = aws_iam_policy.dlm.arn
}


# ===============================================================================
# AWS IAM Policy to enforce MFA (for IAM Users and IAM Groups)
# ===============================================================================
resource "aws_iam_policy" "enforce_mfa" {
  name        = "${local.project}-common-iam-enforce-mfa-policy"
  path        = "/"
  policy      = data.aws_iam_policy_document.enforce_mfa.json
  description = "AWS IAM Policy to enforce MFA devices authentication."

  tags = {
    Name = "${local.project}-common-iam-enforce-mfa-policy"
  }
}

data "aws_iam_policy_document" "enforce_mfa" {
  statement {
    sid    = "EnforceMFA"
    effect = "Deny"
    not_actions = [
      "iam:ListVirtualMFADevices",
      "iam:CreateVirtualMFADevice",
      "iam:DeleteVirtualMFADevice",
      "iam:DeactivateMFADevice",
      "iam:EnableMFADevice",
      "iam:ResyncMFADevice",
      "iam:ListMFADevices",
      "iam:ChangePassword",
      "iam:ReadOnlyAccess",
    ]
    resources = [
      "*",
    ]
    condition {
      test     = "BoolIfExists"
      variable = "aws:MultiFactorAuthPresent"
      values = [
        "false",
      ]
    }
  }

  statement {
    sid    = "ExcludeTerraformStateFilesAccess"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
    ]
    resources = [
      "arn:aws:s3:::v-terraform-web-template-${local.env}",
      "arn:aws:s3:::v-terraform-web-template-${local.env}/*",
    ]
  }
}


# ===============================================================================
# AWS IAM Policy to revoke AWS Cloud9 access (for IAM Users and IAM Groups)
# ===============================================================================
resource "aws_iam_policy" "deny_cloud9_access" {
  name        = "${local.project}-common-iam-deny-cloud9-access-policy"
  path        = "/"
  policy      = data.aws_iam_policy_document.deny_cloud9_access.json
  description = "AWS IAM Policy to revoke AWS Cloud9 access."

  tags = {
    Name = "${local.project}-common-iam-deny-cloud9-access-policy"
  }
}

data "aws_iam_policy_document" "deny_cloud9_access" {
  statement {
    sid    = "DenyCloud9Access"
    effect = "Deny"
    actions = [
      "cloud9:*",
    ]
    resources = [
      "*",
    ]
  }
}


# ===============================================================================
# AWS IAM Policy to allow MFA devices configure (for IAM Users and IAM Groups)
# ===============================================================================
resource "aws_iam_policy" "allow_mfa_configure" {
  name        = "${local.project}-common-iam-allow-mfa-configure-policy"
  path        = "/"
  policy      = data.aws_iam_policy_document.allow_mfa_configure.json
  description = "AWS IAM Policy to allow MFA devices configure."
  tags = {
    Name = "${local.project}-common-iam-allow-mfa-configure-policy"
  }
}

data "aws_iam_policy_document" "allow_mfa_configure" {
  statement {
    sid    = "AllowMFAConfigure"
    effect = "Allow"
    actions = [
      "iam:ListVirtualMFADevices",
      "iam:CreateVirtualMFADevice",
      "iam:DeleteVirtualMFADevice",
      "iam:DeactivateMFADevice",
      "iam:EnableMFADevice",
      "iam:ResyncMFADevice",
      "iam:ListMFADevices",
      "iam:ChangePassword",
    ]
    resources = [
      "*",
    ]
  }
}
