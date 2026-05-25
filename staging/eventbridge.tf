# ===============================================================================
# Amazon EventBridge Scheduler (Amazon RDS Control)
# ===============================================================================
resource "aws_scheduler_schedule_group" "rds_control" {
  name = "${local.project}-${local.env}-eb-scheduler-group-rds-control"

  tags = {
    Name = "${local.project}-${local.env}-eb-scheduler-group-rds-control"
  }
}

resource "aws_scheduler_schedule" "rds_control_start" {
  name        = "${local.project}-${local.env}-eb-scheduler-rds-control-start"
  description = "Amazon RDS Control Start Schedule"
  group_name  = aws_scheduler_schedule_group.rds_control.name
  state       = "ENABLED"

  schedule_expression          = "cron(0 9 ? * MON-FRI *)"
  schedule_expression_timezone = "Asia/Tokyo"

  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:rds:startDBCluster"
    role_arn = aws_iam_role.event_bridge_scheduler.arn

    input = jsonencode({
      "DbClusterIdentifier" : aws_rds_cluster.aurora.cluster_identifier
    })
  }
}

resource "aws_scheduler_schedule" "rds_control_stop" {
  name        = "${local.project}-${local.env}-eb-scheduler-rds-control-stop"
  description = "Amazon RDS Control Stop Schedule"
  group_name  = aws_scheduler_schedule_group.rds_control.name
  state       = "ENABLED"

  schedule_expression          = "cron(0 18 ? * MON-FRI *)"
  schedule_expression_timezone = "Asia/Tokyo"

  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:rds:stopDBCluster"
    role_arn = aws_iam_role.event_bridge_scheduler.arn

    input = jsonencode({
      "DbClusterIdentifier" : aws_rds_cluster.aurora.cluster_identifier
    })
  }
}

resource "aws_cloudwatch_event_target" "rds_control_start" {
  rule      = aws_scheduler_schedule.rds_control_start.name
  target_id = aws_sns_topic.event_notification.name
  arn       = aws_sns_topic.event_notification.arn
}

resource "aws_cloudwatch_event_target" "rds_control_stop" {
  rule      = aws_scheduler_schedule.rds_control_stop.name
  target_id = aws_sns_topic.event_notification.name
  arn       = aws_sns_topic.event_notification.arn
}


# ===============================================================================
# Amazon EventBridge (Amazon ECR Image Scan Notification)
# ===============================================================================
resource "aws_cloudwatch_event_rule" "ecr_image_scan" {
  name           = "${local.project}-${local.env}-eb-ecr-image-scan"
  description    = "Amazon ECR Image Scan Notification"
  event_bus_name = "default"

  event_pattern = jsonencode({
    "source" : [
      "aws.ecr"
    ],
    "detail-type" : [
      "ECR Image Scan"
    ]
  })

  tags = {
    Name = "${local.project}-${local.env}-eb-ecr-image-scan"
  }
}

resource "aws_cloudwatch_event_target" "ecr_image_scan" {
  rule      = aws_cloudwatch_event_rule.ecr_image_scan.name
  target_id = aws_sns_topic.event_notification.name
  arn       = aws_sns_topic.event_notification.arn
}


# ===============================================================================
# Amazon EventBridge Rule (Detect Amazon ECS Task Retirement)
# ===============================================================================
resource "aws_cloudwatch_event_rule" "detect_ecs_task_retirement" {
  name           = "${local.project}-${local.env}-eb-detect-ecs-task-retirement"
  description    = "Detect Amazon ECS Task Retirement"
  event_bus_name = "default"

  event_pattern = jsonencode({
    "source" : [
      "aws.health"
    ],
    "detail-type" : [
      "AWS Health Event"
    ],
    "detail" : {
      "service" : [
        "ECS"
      ],
      "eventTypeCode" : [
        "AWS_ECS_TASK_RETIREMENT"
      ]
    }
  })

  tags = {
    Name = "${local.project}-${local.env}-eb-detect-ecs-task-retirement"
  }
}

resource "aws_cloudwatch_event_target" "detect_ecs_task_retirement" {
  rule      = aws_cloudwatch_event_rule.detect_ecs_task_retirement.name
  target_id = aws_lambda_function.lambda_schedule_ecs_maintenance.function_name
  arn       = aws_lambda_function.lambda_schedule_ecs_maintenance.arn
}


# ===============================================================================
# Amazon EventBridge Rule (Detect Amazon SES Bounce)
# ===============================================================================
resource "aws_cloudwatch_event_rule" "detect_ses_bounce" {
  name           = "${local.project}-${local.env}-eb-detect-ses-bounce"
  description    = "Detect Amazon SES Bounce"
  event_bus_name = "default"

  event_pattern = jsonencode({
    "source" : [
      "aws.ses"
    ],
    "detail-type" : [
      "SES Email Bounce"
    ]
  })

  tags = {
    Name = "${local.project}-${local.env}-eb-detect-ses-bounce"
  }
}

resource "aws_cloudwatch_event_target" "detect_ses_bounce" {
  rule      = aws_cloudwatch_event_rule.detect_ses_bounce.name
  target_id = aws_sns_topic.event_notification.name
  arn       = aws_sns_topic.event_notification.arn
}


# ===============================================================================
# Amazon EventBridge Rule (Detect Amazon SES Complaint)
# ===============================================================================
resource "aws_cloudwatch_event_rule" "detect_ses_complaint" {
  name           = "${local.project}-${local.env}-eb-detect-ses-complaint"
  description    = "Detect Amazon SES Complaint"
  event_bus_name = "default"

  event_pattern = jsonencode({
    "source" : [
      "aws.ses"
    ],
    "detail-type" : [
      "SES Email Complaint"
    ]
  })

  tags = {
    Name = "${local.project}-${local.env}-eb-detect-ses-complaint"
  }
}

resource "aws_cloudwatch_event_target" "detect_ses_complaint" {
  rule      = aws_cloudwatch_event_rule.detect_ses_complaint.name
  target_id = aws_sns_topic.event_notification.name
  arn       = aws_sns_topic.event_notification.arn
}
