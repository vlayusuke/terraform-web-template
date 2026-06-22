# ===============================================================================
# Amazon CloudWatch Log group for Amazon ECS
# ===============================================================================
resource "aws_cloudwatch_log_group" "fargate_app" {
  for_each          = local.fargate_app_cloudwatch_log_group
  name              = "${local.project}-${local.env}-cwt-${each.key}-cwtlog"
  retention_in_days = local.retention_in_days

  tags = {
    Name = "${local.project}-${local.env}-cwt-${each.key}-cwtlog"
  }
}

resource "aws_cloudwatch_log_stream" "fargate_app" {
  for_each       = local.fargate_app_cloudwatch_log_group
  name           = "${local.project}-${local.env}-cwt-${each.key}-cwtstream"
  log_group_name = "${local.project}-${local.env}-cwt-${each.key}-cwtlog"
}

resource "aws_cloudwatch_log_subscription_filter" "fargate_app_to_lambda" {
  for_each        = local.fargate_app_cloudwatch_log_group
  name            = "${local.project}-${local.env}-cwt-${each.key}-to-lmd"
  log_group_name  = "${local.project}-${local.env}-cwt-${each.key}-cwtlog"
  filter_pattern  = "{ $.level_name = \"ERROR\" || $.level_name = \"CRITICAL\" || $.level_name = \"ALERT\" || $.level_name = \"EMERGENCY\" }"
  destination_arn = aws_lambda_function.lambda_log_error_alert.arn
}

resource "aws_cloudwatch_log_subscription_filter" "fargate_app_to_firehose" {
  for_each        = local.fargate_app_cloudwatch_log_group
  name            = "${local.project}-${local.env}-cwt-${each.key}-to-adf"
  log_group_name  = aws_cloudwatch_log_group.fargate_app[each.key].name
  filter_pattern  = ""
  destination_arn = aws_kinesis_firehose_delivery_stream.ecs_logs_app[each.key].arn
  role_arn        = aws_iam_role.cloudwatch_logs_to_amazon_data_firehose.arn
}

resource "aws_cloudwatch_log_group" "fargate_nginx" {
  for_each          = local.fargate_nginx_cloudwatch_log_group
  name              = "${local.project}-${local.env}-cwt-${each.key}-cwtlog"
  retention_in_days = local.retention_in_days

  tags = {
    Name = "${local.project}-${local.env}-cwt-${each.key}-cwtlog"
  }
}

resource "aws_cloudwatch_log_stream" "fargate_nginx" {
  for_each       = local.fargate_nginx_cloudwatch_log_group
  name           = "${local.project}-${local.env}-cwt-${each.key}-cwtstream"
  log_group_name = "${local.project}-${local.env}-cwt-${each.key}-cwtlog"
}

resource "aws_cloudwatch_log_subscription_filter" "fargate_nginx_to_lambda" {
  for_each        = local.fargate_nginx_cloudwatch_log_group
  name            = "${local.project}-${local.env}-cwt-${each.key}-to-lmd"
  log_group_name  = "${local.project}-${local.env}-cwt-${each.key}-cwtlog"
  filter_pattern  = "{ $.status = \"5*\" || $.request_time >= 3.000 }"
  destination_arn = aws_lambda_function.lambda_log_error_alert.arn
}

resource "aws_cloudwatch_log_subscription_filter" "fargate_nginx_to_firehose" {
  for_each        = local.fargate_nginx_cloudwatch_log_group
  name            = "${local.project}-${local.env}-cwt-${each.key}-to-adf"
  log_group_name  = aws_cloudwatch_log_group.fargate_nginx[each.key].name
  filter_pattern  = ""
  destination_arn = aws_kinesis_firehose_delivery_stream.ecs_logs_nginx[each.key].arn
  role_arn        = aws_iam_role.cloudwatch_logs_to_amazon_data_firehose.arn
}


# ===============================================================================
# Amazon CloudWatch Log group for Amazon RDS / Amazon Aurora
# ===============================================================================
resource "aws_cloudwatch_log_group" "rds" {
  for_each          = local.aurora_cloudwatch_log_group
  name              = "/aws/rds/cluster/${aws_rds_cluster.aurora.cluster_identifier}/${each.key}-cwtlog"
  retention_in_days = local.retention_in_days

  tags = {
    Name = "/aws/rds/cluster/${aws_rds_cluster.aurora.cluster_identifier}/${each.key}-cwtlog"
  }
}

resource "aws_cloudwatch_log_stream" "rds" {
  for_each       = local.aurora_cloudwatch_log_group
  name           = "${local.project}-${local.env}-cwt-rds-${each.key}-cwtstream"
  log_group_name = aws_cloudwatch_log_group.rds[each.key].name
}

resource "aws_cloudwatch_log_subscription_filter" "rds_to_lambda" {
  for_each        = local.aurora_cloudwatch_log_group
  name            = "${local.project}-${local.env}-cwt-rds-${each.key}-to-lmd"
  log_group_name  = aws_cloudwatch_log_group.rds[each.key].name
  filter_pattern  = "?Warning ?Error"
  destination_arn = aws_lambda_function.lambda_log_error_alert.arn
}

resource "aws_cloudwatch_log_subscription_filter" "rds_to_firehose" {
  for_each        = local.aurora_adf_stream_arns
  name            = "${local.project}-${local.env}-cwt-rds-${each.key}-to-adf"
  log_group_name  = aws_cloudwatch_log_group.rds[each.key].name
  filter_pattern  = ""
  destination_arn = each.value
  role_arn        = aws_iam_role.cloudwatch_logs_to_amazon_data_firehose.arn
}


# ===============================================================================
# Amazon CloudWatch Log group for Amazon ElastiCache
# ===============================================================================
resource "aws_cloudwatch_log_group" "elasticache" {
  name              = "/aws/elasticache/${local.project}-${local.env}-elc-redis-cluster"
  retention_in_days = local.retention_in_days

  tags = {
    Name = "/aws/elasticache/${local.project}-${local.env}-elc-redis-cluster"
  }
}

resource "aws_cloudwatch_log_stream" "elasticache" {
  name           = "${local.project}-${local.env}-cwt-elc-redis-cwtstream"
  log_group_name = aws_cloudwatch_log_group.elasticache.name
}

resource "aws_cloudwatch_log_subscription_filter" "elasticache_to_lambda" {
  name            = "${local.project}-${local.env}-cwt-elc-redis-to-lmd"
  log_group_name  = aws_cloudwatch_log_group.elasticache.name
  filter_pattern  = "?Warning ?Error"
  destination_arn = aws_lambda_function.lambda_log_error_alert.arn
}

resource "aws_cloudwatch_log_subscription_filter" "elasticache_to_firehose" {
  name            = "${local.project}-${local.env}-cwt-elc-redis-to-adf"
  log_group_name  = aws_cloudwatch_log_group.elasticache.name
  filter_pattern  = ""
  destination_arn = aws_kinesis_firehose_delivery_stream.elasticache_logs.arn
  role_arn        = aws_iam_role.cloudwatch_logs_to_amazon_data_firehose.arn
}


# ===============================================================================
# Amazon CloudWatch Log group for AWS Lambda Functions
# ===============================================================================
resource "aws_cloudwatch_log_group" "lambda_functions" {
  for_each          = local.lambda_functions
  name              = "/aws/lambda/${each.key}-cwtlog"
  retention_in_days = local.retention_in_days

  tags = {
    Name = "/aws/lambda/${each.key}-cwtlog"
  }
}

resource "aws_cloudwatch_log_stream" "lambda_functions" {
  for_each       = local.lambda_functions
  name           = "${local.project}-${local.env}-cwt-lmd-${each.key}-cwtstream"
  log_group_name = aws_cloudwatch_log_group.lambda_functions[each.key].name
}

resource "aws_cloudwatch_log_subscription_filter" "lambda_functions_to_lambda" {
  for_each        = local.lambda_functions
  name            = "${local.project}-${local.env}-cwt-${each.key}-to-lmd"
  log_group_name  = aws_cloudwatch_log_group.lambda_functions[each.key].name
  filter_pattern  = "ERROR"
  destination_arn = aws_lambda_function.lambda_log_error_alert.arn
}

resource "aws_cloudwatch_log_subscription_filter" "lambda_function_to_firehose" {
  for_each        = local.lambda_functions
  name            = "${local.project}-${local.env}-cwt-${each.key}-to-adf"
  log_group_name  = aws_cloudwatch_log_group.lambda_functions[each.key].name
  filter_pattern  = ""
  destination_arn = aws_kinesis_firehose_delivery_stream.lambda_logs[each.key].arn
  role_arn        = aws_iam_role.cloudwatch_logs_to_amazon_data_firehose.arn
}


# ===============================================================================
# Amazon CloudWatch Log group for Amazon SES
# ===============================================================================
resource "aws_cloudwatch_log_group" "ses" {
  name              = "${local.project}-${local.env}-cwt-ses-cwtlog"
  retention_in_days = local.retention_in_days

  tags = {
    Name = "${local.project}-${local.env}-cwt-ses-cwtlog"
  }
}

resource "aws_cloudwatch_log_stream" "ses" {
  name           = "${local.project}-${local.env}-cwt-ses-cwtstream"
  log_group_name = aws_cloudwatch_log_group.ses.name
}

resource "aws_cloudwatch_log_subscription_filter" "ses_to_lambda" {
  name            = "${local.project}-${local.env}-cwt-ses-to-lmd"
  log_group_name  = aws_cloudwatch_log_group.ses.name
  filter_pattern  = "?bounce ?complaint"
  destination_arn = aws_lambda_function.lambda_log_error_alert.arn
}

resource "aws_cloudwatch_log_subscription_filter" "ses_to_firehose" {
  name            = "${local.project}-${local.env}-cwt-ses-to-adf"
  log_group_name  = aws_cloudwatch_log_group.ses.name
  filter_pattern  = ""
  destination_arn = aws_kinesis_firehose_delivery_stream.ses_event_logs.arn
  role_arn        = aws_iam_role.cloudwatch_logs_to_amazon_data_firehose.arn
}


# ===============================================================================
# Amazon CloudWatch Log group for Amazon SNS
# ===============================================================================
resource "aws_cloudwatch_log_group" "sns" {
  name              = "${local.project}-${local.env}-cwt-sns-cwtlog"
  retention_in_days = local.retention_in_days

  tags = {
    Name = "${local.project}-${local.env}-cwt-sns-cwtlog"
  }
}

resource "aws_cloudwatch_log_stream" "sns" {
  name           = "${local.project}-${local.env}-cwt-sns-cwtstream"
  log_group_name = aws_cloudwatch_log_group.sns.name
}

resource "aws_cloudwatch_log_subscription_filter" "sns_to_lambda" {
  name            = "${local.project}-${local.env}-cwt-sns-to-lmd"
  log_group_name  = aws_cloudwatch_log_group.sns.name
  filter_pattern  = ""
  destination_arn = aws_lambda_function.lambda_log_error_alert.arn
}

resource "aws_cloudwatch_log_subscription_filter" "sns_to_firehose" {
  name            = "${local.project}-${local.env}-cwt-sns-to-adf"
  log_group_name  = aws_cloudwatch_log_group.sns.name
  filter_pattern  = ""
  destination_arn = aws_kinesis_firehose_delivery_stream.sns_event_logs.arn
  role_arn        = aws_iam_role.cloudwatch_logs_to_amazon_data_firehose.arn
}


# ===============================================================================
# Amazon CloudWatch Log group for Amazon Data Firehose
# ===============================================================================
resource "aws_cloudwatch_log_group" "adf" {
  name              = "/aws/kinesisfirehose/${local.project}-${local.env}-cwtlog"
  retention_in_days = local.retention_in_days

  tags = {
    Name = "/aws/kinesisfirehose/${local.project}-${local.env}-cwtlog"
  }
}

resource "aws_cloudwatch_log_stream" "adf" {
  name           = "${local.project}-${local.env}-cwt-adf-cwtstream"
  log_group_name = aws_cloudwatch_log_group.adf.name
}


# ================================================================================
# Amazon CloudWatch Log group for Amazon EC2 Bastion
# ================================================================================
resource "aws_cloudwatch_log_group" "ec2_bastion" {
  name              = "${local.project}-${local.env}-cwt-ec2-bastion-cwtlog"
  retention_in_days = local.retention_in_days

  tags = {
    Name = "${local.project}-${local.env}-cwt-ec2-bastion-cwtlog"
  }
}

resource "aws_cloudwatch_log_stream" "ec2_bastion" {
  name           = "${local.project}-${local.env}-cwt-ec2-bastion-cwtstream"
  log_group_name = aws_cloudwatch_log_group.ec2_bastion.name
}

resource "aws_cloudwatch_log_subscription_filter" "ec2_bastion_to_lambda" {
  name            = "${local.project}-${local.env}-cwt-ec2-bastion-to-lmd"
  log_group_name  = aws_cloudwatch_log_group.ec2_bastion.name
  filter_pattern  = ""
  destination_arn = aws_lambda_function.lambda_log_error_alert.arn
}

resource "aws_cloudwatch_log_subscription_filter" "ec2_bastion_to_firehose" {
  name            = "${local.project}-${local.env}-cwt-ec2-bastion-to-adf"
  log_group_name  = aws_cloudwatch_log_group.ec2_bastion.name
  filter_pattern  = ""
  destination_arn = aws_kinesis_firehose_delivery_stream.bastion_logs.arn
  role_arn        = aws_iam_role.cloudwatch_logs_to_amazon_data_firehose.arn
}


# ===============================================================================
# Amazon CloudWatch Metrics for Amazon ECS (app)
# ===============================================================================
resource "aws_cloudwatch_metric_alarm" "app_cpu_high" {
  alarm_name          = "${local.project}-${local.env}-cwt-ecs-app-cpu-high-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Maximum"
  threshold           = 80
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.fargate_app.name
  }

  alarm_actions = [
    aws_appautoscaling_policy.fargate_app_scale_out.arn,
    aws_sns_topic.metric_alarm.arn,
  ]

  ok_actions = [
    aws_sns_topic.metric_alarm.arn,
  ]

  tags = {
    Name = "${local.project}-${local.env}-cwt-ecs-app-cpu-high-alarm"
  }
}

resource "aws_cloudwatch_metric_alarm" "app_cpu_low" {
  alarm_name          = "${local.project}-${local.env}-cwt-ecs-app-cpu-low-alarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 10
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Maximum"
  threshold           = 15
  treat_missing_data  = "notBreaching"
  datapoints_to_alarm = 10

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.fargate_app.name
  }

  alarm_actions = [
    aws_appautoscaling_policy.fargate_app_scale_in.arn,
    aws_sns_topic.metric_alarm.arn,
  ]

  ok_actions = [
    aws_sns_topic.metric_alarm.arn,
  ]

  tags = {
    Name = "${local.project}-${local.env}-cwt-ecs-app-cpu-low-alarm"
  }
}

resource "aws_cloudwatch_metric_alarm" "app_memory_high" {
  alarm_name          = "${local.project}-${local.env}-cwt-ecs-app-memory-high-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Maximum"
  threshold           = 80
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.fargate_app.name
  }

  alarm_actions = [
    aws_appautoscaling_policy.fargate_app_scale_out.arn,
    aws_sns_topic.metric_alarm.arn,
  ]

  ok_actions = [
    aws_sns_topic.metric_alarm.arn,
  ]

  tags = {
    Name = "${local.project}-${local.env}-cwt-ecs-app-memory-high-alarm"
  }
}


# ===============================================================================
# Amazon CloudWatch Metrics for Amazon ECS (cron)
# ===============================================================================
resource "aws_cloudwatch_metric_alarm" "cron_cpu_high" {
  alarm_name          = "${local.project}-${local.env}-cwt-ecs-cron-cpu-high-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Maximum"
  threshold           = 80
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.fargate_cron.name
  }

  alarm_actions = [
    aws_sns_topic.metric_alarm.arn,
  ]

  ok_actions = [
    aws_sns_topic.metric_alarm.arn,
  ]

  tags = {
    Name = "${local.project}-${local.env}-cwt-ecs-cron-cpu-high-alarm"
  }
}

resource "aws_cloudwatch_metric_alarm" "cron_memory_high" {
  alarm_name          = "${local.project}-${local.env}-cwt-ecs-cron-memory-high-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Maximum"
  threshold           = 80
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.fargate_cron.name
  }

  alarm_actions = [
    aws_sns_topic.metric_alarm.arn,
  ]

  ok_actions = [
    aws_sns_topic.metric_alarm.arn,
  ]

  tags = {
    Name = "${local.project}-${local.env}-cwt-ecs-cron-memory-high-alarm"
  }
}


# ===============================================================================
# Amazon CloudWatch Metrics for Amazon ECS (queue)
# ===============================================================================
resource "aws_cloudwatch_metric_alarm" "queue_cpu_high" {
  alarm_name          = "${local.project}-${local.env}-cwt-ecs-queue-cpu-high-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Maximum"
  threshold           = 80
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.fargate_queue.name
  }

  alarm_actions = [
    aws_sns_topic.metric_alarm.arn,
  ]

  ok_actions = [
    aws_sns_topic.metric_alarm.arn,
  ]

  tags = {
    Name = "${local.project}-${local.env}-cwt-ecs-queue-cpu-high-alarm"
  }
}

resource "aws_cloudwatch_metric_alarm" "queue_memory_high" {
  alarm_name          = "${local.project}-${local.env}-cwt-ecs-queue-memory-high-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Maximum"
  threshold           = 80
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.fargate_queue.name
  }

  alarm_actions = [
    aws_sns_topic.metric_alarm.arn,
  ]

  ok_actions = [
    aws_sns_topic.metric_alarm.arn,
  ]

  tags = {
    Name = "${local.project}-${local.env}-cwt-ecs-queue-memory-high-alarm"
  }
}


# ===============================================================================
# Amazon CloudWatch Metrics for Application Load Balancer
# ===============================================================================
resource "aws_cloudwatch_metric_alarm" "alb_healthy_host_count" {
  alarm_name          = "${local.project}-${local.env}-cwt-alb-healthy-host-count-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "HealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Minimum"
  threshold           = 0
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = aws_lb.main_external.arn
    TargetGroup  = aws_lb_target_group.alb_external_tg.arn
  }

  alarm_actions = [
    aws_sns_topic.metric_alarm.arn,
  ]

  ok_actions = [
    aws_sns_topic.metric_alarm.arn,
  ]

  tags = {
    Name = "${local.project}-${local.env}-cwt-alb-healthy-host-count-alarm"
  }
}

resource "aws_cloudwatch_metric_alarm" "alb_un_healthy_host_count" {
  alarm_name          = "${local.project}-${local.env}-cwt-alb-un-healthy-host-count-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Maximum"
  threshold           = 1
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = aws_lb.main_external.arn
    TargetGroup  = aws_lb_target_group.alb_external_tg.arn
  }

  alarm_actions = [
    aws_sns_topic.metric_alarm.arn,
  ]

  ok_actions = [
    aws_sns_topic.metric_alarm.arn,
  ]

  tags = {
    Name = "${local.project}-${local.env}-cwt-alb-un-healthy-host-count-alarm"
  }
}

resource "aws_cloudwatch_metric_alarm" "alb_rejected_connection" {
  alarm_name          = "${local.project}-${local.env}-cwt-alb-rejected-connection-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "RejectedConnectionCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = aws_lb.main_external.arn
    TargetGroup  = aws_lb_target_group.alb_external_tg.arn
  }

  alarm_actions = [
    aws_sns_topic.metric_alarm.arn,
  ]

  ok_actions = [
    aws_sns_topic.metric_alarm.arn,
  ]

  tags = {
    Name = "${local.project}-${local.env}-cwt-alb-rejected-connection-alarm"
  }
}


# ===============================================================================
# Amazon CloudWatch Metrics for Amazon RDS / Amazon Aurora
# ===============================================================================
resource "aws_cloudwatch_metric_alarm" "rds_cpu_high" {
  alarm_name          = "${local.project}-${local.env}-cwt-rds-cpu-high-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 60
  statistic           = "Maximum"
  threshold           = 80
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBClusterIdentifier = aws_rds_cluster.aurora.id
  }

  alarm_actions = [
    aws_sns_topic.metric_alarm.arn,
  ]

  ok_actions = [
    aws_sns_topic.metric_alarm.arn,
  ]

  tags = {
    Name = "${local.project}-${local.env}-cwt-rds-cpu-high-alarm"
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_memory_high" {
  alarm_name          = "${local.project}-${local.env}-cwt-rds-memory-high-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "FreeableMemory"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Minimum"
  threshold           = 256000000
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBClusterIdentifier = aws_rds_cluster.aurora.id
  }

  alarm_actions = [
    aws_sns_topic.metric_alarm.arn,
  ]

  ok_actions = [
    aws_sns_topic.metric_alarm.arn,
  ]

  tags = {
    Name = "${local.project}-${local.env}-cwt-rds-memory-high-alarm"
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_connections_high" {
  alarm_name          = "${local.project}-${local.env}-cwt-rds-connections-high-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = 60
  statistic           = "Maximum"
  threshold           = floor(local.rds_max_connections * 0.8)
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBClusterIdentifier = aws_rds_cluster.aurora.id
  }

  alarm_actions = [
    aws_sns_topic.metric_alarm.arn,
  ]

  ok_actions = [
    aws_sns_topic.metric_alarm.arn,
  ]

  tags = {
    Name = "${local.project}-${local.env}-cwt-rds-connections-high-alarm"
  }
}


# ===============================================================================
# Amazon CloudWatch Metrics for Amazon ElastiCache
# ===============================================================================
resource "aws_cloudwatch_metric_alarm" "elasticache_cpu_high" {
  alarm_name          = "${local.project}-${local.env}-cwt-elc-cpu-high-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ElastiCache"
  period              = 60
  statistic           = "Maximum"
  threshold           = 80
  treat_missing_data  = "notBreaching"

  dimensions = {
    CacheClusterId = aws_elasticache_replication_group.redis.replication_group_id
  }

  alarm_actions = [
    aws_sns_topic.metric_alarm.arn,
  ]

  ok_actions = [
    aws_sns_topic.metric_alarm.arn,
  ]

  tags = {
    Name = "${local.project}-${local.env}-cwt-elc-cpu-high-alarm"
  }
}

resource "aws_cloudwatch_metric_alarm" "elasticache_memory_high" {
  alarm_name          = "${local.project}-${local.env}-cwt-elc-memory-high-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "DatabaseMemoryUsagePercentage"
  namespace           = "AWS/ElastiCache"
  period              = 60
  statistic           = "Maximum"
  threshold           = 80
  treat_missing_data  = "notBreaching"

  dimensions = {
    CacheClusterId = aws_elasticache_replication_group.redis.replication_group_id
  }

  alarm_actions = [
    aws_sns_topic.metric_alarm.arn,
  ]

  ok_actions = [
    aws_sns_topic.metric_alarm.arn,
  ]

  tags = {
    Name = "${local.project}-${local.env}-cwt-elc-memory-high-alarm"
  }
}

resource "aws_cloudwatch_metric_alarm" "elasticache_swap_high" {
  alarm_name          = "${local.project}-${local.env}-cwt-elc-swap-high-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "SwapUsage"
  namespace           = "AWS/ElastiCache"
  period              = 300
  statistic           = "Maximum"
  threshold           = 50000000
  treat_missing_data  = "notBreaching"

  dimensions = {
    CacheClusterId = aws_elasticache_replication_group.redis.replication_group_id
  }

  alarm_actions = [
    aws_sns_topic.metric_alarm.arn,
  ]

  ok_actions = [
    aws_sns_topic.metric_alarm.arn,
  ]

  tags = {
    Name = "${local.project}-${local.env}-cwt-elc-swap-high-alarm"
  }
}


# ===============================================================================
# Amazon CloudWatch Metrics for Amazon SES
# ===============================================================================
resource "aws_cloudwatch_metric_alarm" "ses_complaint_rate" {
  alarm_name          = "${local.project}-${local.env}-cwt-ses-complaint-rate-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "Reputation.ComplaintRate"
  namespace           = "AWS/SES"
  period              = 300
  statistic           = "Maximum"
  threshold           = 0.001
  treat_missing_data  = "notBreaching"

  alarm_actions = [
    aws_sns_topic.metric_alarm.arn,
  ]

  ok_actions = [
    aws_sns_topic.metric_alarm.arn,
  ]

  tags = {
    Name = "${local.project}-${local.env}-cwt-ses-complaint-rate-alarm"
  }
}

resource "aws_cloudwatch_metric_alarm" "ses_bounce_rate" {
  alarm_name          = "${local.project}-${local.env}-cwt-ses-bounce-rate-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "Reputation.BounceRate"
  namespace           = "AWS/SES"
  period              = 300
  statistic           = "Maximum"
  threshold           = 0.001
  treat_missing_data  = "notBreaching"

  alarm_actions = [
    aws_sns_topic.metric_alarm.arn,
  ]

  ok_actions = [
    aws_sns_topic.metric_alarm.arn,
  ]

  tags = {
    Name = "${local.project}-${local.env}-cwt-ses-bounce-rate-alarm"
  }
}


# ===============================================================================
# Amazon CloudWatch Metrics for AWS Lambda
# ===============================================================================
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "${local.project}-${local.env}-cwt-lmd-errors-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  treat_missing_data  = "notBreaching"

  alarm_actions = [
    aws_sns_topic.metric_alarm.arn,
  ]

  ok_actions = [
    aws_sns_topic.metric_alarm.arn,
  ]

  tags = {
    Name = "${local.project}-${local.env}-cwt-lmd-errors-alarm"
  }
}

resource "aws_cloudwatch_metric_alarm" "lambda_throttles" {
  alarm_name          = "${local.project}-${local.env}-cwt-lmd-throttles-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "Throttles"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  treat_missing_data  = "notBreaching"

  alarm_actions = [
    aws_sns_topic.metric_alarm.arn,
  ]

  ok_actions = [
    aws_sns_topic.metric_alarm.arn,
  ]

  tags = {
    Name = "${local.project}-${local.env}-cwt-lmd-throttles-alarm"
  }
}

resource "aws_cloudwatch_metric_alarm" "lambda_concurrent_executions" {
  alarm_name          = "${local.project}-${local.env}-cwt-lmd-concurrent-executions-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "ConcurrentExecutions"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Maximum"
  threshold           = data.aws_servicequotas_service_quota.lambda_concurrent_executions.value * 0.8
  treat_missing_data  = "notBreaching"

  alarm_actions = [
    aws_sns_topic.metric_alarm.arn,
  ]

  ok_actions = [
    aws_sns_topic.metric_alarm.arn,
  ]

  tags = {
    Name = "${local.project}-${local.env}-cwt-lmd-concurrent-executions-alarm"
  }
}

data "aws_servicequotas_service_quota" "lambda_concurrent_executions" {
  quota_name   = "Concurrent executions"
  service_code = "lambda"
}


# ================================================================================
# Amazon CloudWatch Metrics for Amazon EC2 Bastion
# ================================================================================
resource "aws_cloudwatch_metric_alarm" "ec2_bastion_cpu_high" {
  alarm_name          = "${local.project}-${local.env}-cwt-ec2-bastion-cpu-high-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Maximum"
  threshold           = 80
  treat_missing_data  = "notBreaching"

  dimensions = {
    InstanceId = aws_instance.ec2_bastion.id
  }

  alarm_actions = [
    aws_sns_topic.metric_alarm.arn,
  ]

  ok_actions = [
    aws_sns_topic.metric_alarm.arn,
  ]

  tags = {
    Name = "${local.project}-${local.env}-cwt-ec2-bastion-cpu-high-alarm"
  }
}

resource "aws_cloudwatch_metric_alarm" "ec2_bastion_memory_high" {
  alarm_name          = "${local.project}-${local.env}-cwt-ec2-bastion-memory-high-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Maximum"
  threshold           = 80
  treat_missing_data  = "notBreaching"

  dimensions = {
    InstanceId = aws_instance.ec2_bastion.id
  }

  alarm_actions = [
    aws_sns_topic.metric_alarm.arn,
  ]

  ok_actions = [
    aws_sns_topic.metric_alarm.arn,
  ]

  tags = {
    Name = "${local.project}-${local.env}-cwt-ec2-bastion-memory-high-alarm"
  }
}

resource "aws_cloudwatch_metric_alarm" "ec2_bastion_disk_high" {
  alarm_name          = "${local.project}-${local.env}-cwt-ec2-bastion-disk-high-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "DiskUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Maximum"
  threshold           = 80
  treat_missing_data  = "notBreaching"

  dimensions = {
    InstanceId = aws_instance.ec2_bastion.id
  }

  alarm_actions = [
    aws_sns_topic.metric_alarm.arn,
  ]

  ok_actions = [
    aws_sns_topic.metric_alarm.arn,
  ]

  tags = {
    Name = "${local.project}-${local.env}-cwt-ec2-bastion-disk-high-alarm"
  }
}

resource "aws_cloudwatch_metric_alarm" "ec2_bastion_status_check_failed" {
  alarm_name          = "${local.project}-${local.env}-cwt-ec2-bastion-status-check-failed-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Minimum"
  threshold           = 1
  treat_missing_data  = "notBreaching"

  dimensions = {
    InstanceId = aws_instance.ec2_bastion.id
  }

  alarm_actions = [
    aws_sns_topic.metric_alarm.arn,
  ]

  ok_actions = [
    aws_sns_topic.metric_alarm.arn,
  ]

  tags = {
    Name = "${local.project}-${local.env}-cwt-ec2-bastion-status-check-failed-alarm"
  }
}


# ================================================================================
# Amazon CloudFront Access Logs V2 to S3 via Amazon CloudWatch Log Delivery
# ================================================================================
resource "aws_cloudwatch_log_delivery_source" "cloudfront_access_logs_v2" {
  provider     = aws.virginia
  name         = "${local.project}-${local.env}-cwt-cft-access-logs-v2-source"
  log_type     = "ACCESS_LOGS"
  resource_arn = aws_cloudfront_distribution.main.arn

  tags = {
    Name = "${local.project}-${local.env}-cwt-cft-access-logs-v2-source"
  }
}

resource "aws_cloudwatch_log_delivery_destination" "cloudfront_access_logs_v2" {
  provider                  = aws.virginia
  name                      = "${local.project}-${local.env}-cwt-cft-access-logs-v2-destination"
  delivery_destination_type = "S3"
  output_format             = "parquet"

  delivery_destination_configuration {
    destination_resource_arn = "${aws_s3_bucket.cloudfront_logs.arn}/v2/"
  }

  tags = {
    Name = "${local.project}-${local.env}-cwt-cft-access-logs-v2-destination"
  }
}

resource "aws_cloudwatch_log_delivery" "cloudfront_access_logs_v2" {
  provider                 = aws.virginia
  delivery_source_name     = aws_cloudwatch_log_delivery_source.cloudfront_access_logs_v2.name
  delivery_destination_arn = aws_cloudwatch_log_delivery_destination.cloudfront_access_logs_v2.arn

  s3_delivery_configuration {
    suffix_path = "/${data.aws_caller_identity.current.account_id}/{DistributionId}/{yyyy}/{MM}/{dd}/{HH}/"
  }

  tags = {
    Name = "${local.project}-${local.env}-cwt-cft-access-logs-v2-delivery"
  }
}
