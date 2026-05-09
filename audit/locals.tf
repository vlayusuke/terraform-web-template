# ================================================================================
# Local Values in audit
# ================================================================================

# ================================================================================
# Environment
# ================================================================================
locals {
  env             = "aud"
  repository_name = "vlayusuke"
  account_id      = data.aws_caller_identity.current.account_id
}


# ================================================================================
# Amazon CloudWatch
# ================================================================================
locals {
  retention_in_days = 180

  lambda_functions = toset([
    aws_lambda_function.root_login_monitoring.function_name,
    aws_lambda_function.lambda_error.function_name,
    aws_lambda_function.security_notice.function_name,
    aws_lambda_function.lambda_log_error_alert_audit.function_name,
  ])
}


# ================================================================================
# AWS Lambda
# ================================================================================
locals {
  ssm_parameter_store_timeout_millis = 3000
}


# ================================================================================
# Amazon S3
# ================================================================================
locals {
  transition_days = 365
  expire_days     = 1827
}
