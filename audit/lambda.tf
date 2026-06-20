# ===============================================================================
# AWS Lambda Function for CloudWatch log error alert audit
# ===============================================================================
resource "aws_lambda_function" "lambda_log_error_alert_audit" {
  function_name    = "aud-lmd-cwt-log-error-alert"
  role             = aws_iam_role.lambda_cloudwatch_audit.arn
  handler          = "lambda_function.lambda_handler"
  filename         = data.archive_file.log_error_alert_audit.output_path
  source_code_hash = data.archive_file.log_error_alert_audit.output_base64sha256
  runtime          = "python3.14"
  timeout          = 10
  memory_size      = 128

  architectures = [
    "arm64",
  ]

  environment {
    variables = {
      hook_url = var.audit_hook_url
    }
  }

  lifecycle {
    ignore_changes = [
      source_code_hash,
    ]
  }

  tags = {
    Name = "${local.project}-${local.env}-lmd-cwt-log-error-alert-audit"
  }
}

data "archive_file" "log_error_alert_audit" {
  type        = "zip"
  source_dir  = "${path.cwd}/files/lambda/log-error-alert-audit"
  output_path = "${path.module}/artifacts/log-error-alert-audit.zip"
}

resource "aws_lambda_permission" "lambda_cloudwatch_audit" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_log_error_alert_audit.function_name
  principal     = "logs.${local.region}.amazonaws.com"
  source_arn    = "arn:aws:logs:${local.region}:${data.aws_caller_identity.current.account_id}:log-group:*:*"
}


# ===============================================================================
# AWS Lambda Function for Root Login
# ===============================================================================
resource "aws_lambda_function" "root_login_monitoring" {
  function_name    = "aud-lmd-root-login-monitoring"
  role             = aws_iam_role.lambda_root_login_monitoring.arn
  handler          = "lambda_function.lambda_handler"
  filename         = data.archive_file.root_login_monitoring.output_path
  source_code_hash = data.archive_file.root_login_monitoring.output_base64sha256
  runtime          = "python3.14"
  timeout          = 10
  memory_size      = 128

  architectures = [
    "arm64",
  ]

  environment {
    variables = {
      account_name = local.project
      hook_url     = var.audit_hook_url
    }
  }

  lifecycle {
    ignore_changes = [
      source_code_hash,
    ]
  }

  tags = {
    Name = "${local.project}-${local.env}-lmd-root-login-monitoring"
  }
}

data "archive_file" "root_login_monitoring" {
  type        = "zip"
  source_dir  = "${path.cwd}/files/lambda/root-login-monitoring"
  output_path = "${path.module}/artifacts/aud-lmd-root-login-monitoring.zip"
}

resource "aws_lambda_permission" "root_login_monitoring" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.root_login_monitoring.function_name
  principal     = "logs.${local.region}.amazonaws.com"
  source_arn    = "${aws_cloudwatch_log_group.root_login_monitoring.arn}:*"
}


# ===============================================================================
# AWS Lambda Function for Lambda Error
# ===============================================================================
resource "aws_lambda_function" "lambda_error" {
  function_name    = "aud-lmd-lambda-error"
  role             = aws_iam_role.lambda_error.arn
  handler          = "lambda_function.lambda_handler"
  filename         = data.archive_file.lambda_error.output_path
  source_code_hash = data.archive_file.lambda_error.output_base64sha256
  runtime          = "python3.14"
  timeout          = 10
  memory_size      = 128

  architectures = [
    "arm64",
  ]

  environment {
    variables = {
      hook_url = var.audit_hook_url
    }
  }

  lifecycle {
    ignore_changes = [
      source_code_hash,
    ]
  }

  tags = {
    Name = "${local.project}-${local.env}-lmd-lambda-error"
  }
}

data "archive_file" "lambda_error" {
  type        = "zip"
  source_dir  = "${path.cwd}/files/lambda/lambda-error"
  output_path = "${path.module}/artifacts/aud-lmd-lambda-error.zip"
}

resource "aws_lambda_permission" "lambda_error" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_error.function_name
  principal     = "logs.${local.region}.amazonaws.com"
  source_arn    = "${aws_cloudwatch_log_group.lambda_error.arn}:*"
}


# ===============================================================================
# AWS Lambda Function for Security Notice
# ===============================================================================
resource "aws_lambda_function" "security_notice" {
  function_name    = "aud-lmd-security-notice"
  role             = aws_iam_role.lambda_security_notice.arn
  handler          = "lambda_function.lambda_handler"
  filename         = data.archive_file.security_notice.output_path
  source_code_hash = data.archive_file.security_notice.output_base64sha256
  runtime          = "python3.14"
  timeout          = 10
  memory_size      = 128

  architectures = [
    "arm64",
  ]

  environment {
    variables = {
      hook_url = var.audit_hook_url
    }
  }

  lifecycle {
    ignore_changes = [
      source_code_hash,
    ]
  }

  tags = {
    Name = "${local.project}-${local.env}-lmd-security-notice"
  }
}

data "archive_file" "security_notice" {
  type        = "zip"
  source_dir  = "${path.cwd}/files/lambda/lambda-security-notice"
  output_path = "${path.module}/artifacts/aud-lmd-security-notice.zip"
}

resource "aws_lambda_permission" "security_notice" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.security_notice.function_name
  principal     = "logs.${local.region}.amazonaws.com"
  source_arn    = "${aws_cloudwatch_log_group.security_notice.arn}:*"
}
