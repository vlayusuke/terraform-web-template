# ===============================================================================
# Amazon ElastiCache
# ===============================================================================
resource "aws_elasticache_replication_group" "redis" {
  replication_group_id       = "${local.project}-${local.env}-elc-redis-cluster"
  description                = "Amazon ElastiCache Replication group for ${local.project}-${local.env}"
  engine                     = "redis"
  engine_version             = local.elasticache_redis_version
  node_type                  = "cache.t4g.medium"
  num_cache_clusters         = 2
  multi_az_enabled           = true
  automatic_failover_enabled = true
  port                       = 6379
  parameter_group_name       = aws_elasticache_parameter_group.redis.id
  subnet_group_name          = aws_elasticache_subnet_group.redis.name
  maintenance_window         = "sat:15:00-sat:16:00"
  snapshot_retention_limit   = 14
  snapshot_window            = "15:00-16:00"
  notification_topic_arn     = aws_sns_topic.event_notifications.arn
  auto_minor_version_upgrade = true
  apply_immediately          = true

  log_delivery_configuration {
    log_format       = "json"
    log_type         = "engine-log"
    destination_type = "cloudwatch-logs"
    destination      = aws_cloudwatch_log_group.elasticache.name
  }

  security_group_ids = [
    aws_security_group.redis.id,
  ]

  tags = {
    Name = "${local.project}-${local.env}-elc-redis-cluster"
  }
}


# ===============================================================================
# Subnet Group
# ===============================================================================
resource "aws_elasticache_subnet_group" "redis" {
  name        = "${local.project}-${local.env}-elc-redis-cluster-subg"
  description = "Subnet group for ${local.project}-${local.env} Amazon ElastiCache Cluster"

  subnet_ids = [
    for subnet in aws_subnet.main_private :
    subnet.id
  ]

  tags = {
    Name = "${local.project}-${local.env}-elc-redis-cluster-subg"
  }
}


# ===============================================================================
# Parameter Group
# ===============================================================================
resource "aws_elasticache_parameter_group" "redis" {
  name        = "${local.project}-${local.env}-elc-redis-cache-params-ecpg"
  description = "Parameter group for ${local.project}-${local.env} Amazon ElastiCache Cluster"
  family      = "redis7"

  parameter {
    name  = "cluster-enabled"
    value = "yes"
  }

  tags = {
    Name = "${local.project}-${local.env}-elc-redis-cache-params-ecpg"
  }
}
