# ===============================================================================
# Amazon ECS Cluster
# ===============================================================================
resource "aws_ecs_cluster" "main" {
  name = "${local.project}-${local.env}-ecs-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = "${local.project}-${local.env}-ecs-cluster"
  }
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name = aws_ecs_cluster.main.name
  capacity_providers = [
    "FARGATE",
    "FARGATE_SPOT",
  ]

  default_capacity_provider_strategy {
    base              = 1
    capacity_provider = "FARGATE"
    weight            = 1
  }
}


# ===============================================================================
# Amazon ECS Service for App
# ===============================================================================
resource "aws_ecs_service" "fargate_app" {
  name                               = "fargate-app"
  cluster                            = aws_ecs_cluster.main.id
  task_definition                    = data.aws_ecs_task_definition.fargate_app.arn
  availability_zone_rebalancing      = "ENABLED"
  desired_count                      = 2
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
  platform_version                   = "1.4.0"
  enable_execute_command             = true
  force_new_deployment               = true

  capacity_provider_strategy {
    base              = 1
    capacity_provider = "FARGATE"
    weight            = 0
  }

  capacity_provider_strategy {
    base              = 0
    capacity_provider = "FARGATE_SPOT"
    weight            = 1
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  deployment_configuration {
    strategy = "ROLLING"
  }

  deployment_controller {
    type = "ECS"
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.alb_external_tg.arn
    container_name   = "nginx"
    container_port   = 80
  }

  network_configuration {
    subnets = [
      for subnet in aws_subnet.main_private :
      subnet.id
    ]
    security_groups = [
      aws_security_group.fargate_app.id,
    ]
  }

  lifecycle {
    ignore_changes = [
      capacity_provider_strategy,
      task_definition,
      desired_count,
    ]
  }

  depends_on = [
    aws_lb_target_group.alb_external_tg,
  ]

  tags = {
    Name = "${local.project}-${local.env}-ecs-service-app"
  }
}

resource "aws_appautoscaling_target" "fargate_app" {
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.fargate_app.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = 2
  max_capacity       = 4

  lifecycle {
    ignore_changes = [
      max_capacity,
      min_capacity,
    ]
  }

  tags = {
    Name = "${local.project}-${local.env}-ecs-app-autoscaling-target"
  }
}

resource "aws_appautoscaling_policy" "fargate_app_scale_out" {
  name               = "${local.project}-${local.env}-ecs-app-scale-out"
  policy_type        = "StepScaling"
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.fargate_app.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 120
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 2
    }
  }

  lifecycle {
    ignore_changes = [
      step_scaling_policy_configuration,
    ]
  }

  depends_on = [
    aws_appautoscaling_target.fargate_app,
  ]
}

resource "aws_appautoscaling_policy" "fargate_app_scale_in" {
  name               = "${local.project}-${local.env}-ecs-app-scale-in"
  policy_type        = "StepScaling"
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.fargate_app.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 600
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }

  lifecycle {
    ignore_changes = [
      step_scaling_policy_configuration,
    ]
  }

  depends_on = [
    aws_appautoscaling_target.fargate_app,
  ]
}


# ===============================================================================
# Amazon ECS Task for App
# ===============================================================================
resource "aws_ecs_task_definition" "fargate_app" {
  family                   = "fargate-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_service.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = templatefile(
    "files/task_definitions/app.json",
    {
      account_id       = data.aws_caller_identity.current.account_id
      project          = local.project
      env              = local.env
      region           = local.region
      log_group_prefix = "${local.project}-${local.env}"
    }
  )

  runtime_platform {
    cpu_architecture        = "ARM64"
    operating_system_family = "LINUX"
  }

  ephemeral_storage {
    size_in_gib = 128
  }

  volume {
    name = "${local.project}-${local.env}-efs-volume"

    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.main.id
      root_directory     = "/"
      transit_encryption = "ENABLED"
    }
  }

  lifecycle {
    ignore_changes = [
      container_definitions,
      volume,
    ]
  }

  tags = {
    Name = "${local.project}-${local.env}-ecs-task-app"
  }
}

data "aws_ecs_task_definition" "fargate_app" {
  task_definition = aws_ecs_task_definition.fargate_app.family
}


# ===============================================================================
# Amazon ECS Service for Cron
# ===============================================================================
resource "aws_ecs_service" "fargate_cron" {
  name                               = "fargate-cron"
  cluster                            = aws_ecs_cluster.main.id
  task_definition                    = data.aws_ecs_task_definition.fargate_cron.arn
  availability_zone_rebalancing      = "ENABLED"
  desired_count                      = 1
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
  platform_version                   = "1.4.0"
  enable_execute_command             = true
  force_new_deployment               = true

  capacity_provider_strategy {
    base              = 1
    capacity_provider = "FARGATE"
    weight            = 1
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  deployment_configuration {
    strategy = "ROLLING"
  }

  deployment_controller {
    type = "ECS"
  }

  network_configuration {
    subnets = [
      for subnet in aws_subnet.main_private :
      subnet.id
    ]
    security_groups = [
      aws_security_group.fargate_cron.id,
    ]
  }

  lifecycle {
    ignore_changes = [
      capacity_provider_strategy,
      task_definition,
      desired_count,
    ]
  }

  tags = {
    Name = "${local.project}-${local.env}-ecs-service-cron"
  }
}


# ===============================================================================
# Amazon ECS Task for Cron
# ===============================================================================
resource "aws_ecs_task_definition" "fargate_cron" {
  family                   = "fargate-cron"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_service.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = templatefile(
    "files/task_definitions/cron.json",
    {
      account_id       = data.aws_caller_identity.current.account_id
      project          = local.project
      env              = local.env
      region           = local.region
      log_group_prefix = "${local.project}-${local.env}"
    }
  )

  runtime_platform {
    cpu_architecture        = "ARM64"
    operating_system_family = "LINUX"
  }

  ephemeral_storage {
    size_in_gib = 64
  }

  lifecycle {
    ignore_changes = [
      container_definitions,
    ]
  }

  tags = {
    Name = "${local.project}-${local.env}-ecs-task-cron"
  }
}

data "aws_ecs_task_definition" "fargate_cron" {
  task_definition = aws_ecs_task_definition.fargate_cron.family
}


# ===============================================================================
# Amazon ECS Service for Queue
# ===============================================================================
resource "aws_ecs_service" "fargate_queue" {
  name                               = "fargate-queue"
  cluster                            = aws_ecs_cluster.main.id
  task_definition                    = data.aws_ecs_task_definition.fargate_queue.arn
  availability_zone_rebalancing      = "ENABLED"
  desired_count                      = 1
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
  platform_version                   = "1.4.0"
  enable_execute_command             = true
  force_new_deployment               = true

  capacity_provider_strategy {
    base              = 1
    capacity_provider = "FARGATE"
    weight            = 1
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  deployment_configuration {
    strategy = "ROLLING"
  }

  deployment_controller {
    type = "ECS"
  }

  network_configuration {
    subnets = [
      for subnet in aws_subnet.main_private :
      subnet.id
    ]
    security_groups = [
      aws_security_group.fargate_queue.id,
    ]
  }

  lifecycle {
    ignore_changes = [
      capacity_provider_strategy,
      task_definition,
      desired_count,
    ]
  }

  tags = {
    Name = "${local.project}-${local.env}-ecs-service-queue"
  }
}


# ===============================================================================
# Amazon ECS Task for Queue
# ===============================================================================
resource "aws_ecs_task_definition" "fargate_queue" {
  family                   = "fargate-queue"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_service.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = templatefile(
    "files/task_definitions/queue.json",
    {
      account_id       = data.aws_caller_identity.current.account_id
      project          = local.project
      env              = local.env
      region           = local.region
      log_group_prefix = "${local.project}-${local.env}"
    }
  )

  runtime_platform {
    cpu_architecture        = "ARM64"
    operating_system_family = "LINUX"
  }

  ephemeral_storage {
    size_in_gib = 64
  }

  lifecycle {
    ignore_changes = [
      container_definitions,
    ]
  }

  tags = {
    Name = "${local.project}-${local.env}-ecs-task-queue"
  }
}

data "aws_ecs_task_definition" "fargate_queue" {
  task_definition = aws_ecs_task_definition.fargate_queue.family
}


# ===============================================================================
# Amazon ECS Task for migrate
# ===============================================================================
resource "aws_ecs_task_definition" "fargate_migrate" {
  family                   = "fargate-migrate"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_service.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = templatefile(
    "files/task_definitions/migrate.json",
    {
      account_id       = data.aws_caller_identity.current.account_id
      project          = local.project
      env              = local.env
      region           = local.region
      log_group_prefix = "${local.project}-${local.env}"
    }
  )

  runtime_platform {
    cpu_architecture        = "ARM64"
    operating_system_family = "LINUX"
  }

  ephemeral_storage {
    size_in_gib = 64
  }

  tags = {
    Name = "${local.project}-${local.env}-ecs-task-migrate"
  }
}


# ===============================================================================
# Amazon ECS Account Default Settings
# Reference: https://github.com/hashicorp/terraform-provider-aws/issues/45696
# ===============================================================================
resource "aws_ecs_account_setting_default" "production" {
  name  = "fargateEventWindows"
  value = "enabled"
}
