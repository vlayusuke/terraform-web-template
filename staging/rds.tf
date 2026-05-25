# ===============================================================================
# Amazon Aurora Cluster
# ===============================================================================
resource "aws_rds_cluster" "aurora" {
  cluster_identifier                    = "${local.project}-${local.env}-aurora-cluster"
  engine                                = "aurora-mysql"
  engine_mode                           = "provisioned"
  engine_version                        = local.aurora_mysql_version
  port                                  = 3306
  database_name                         = local.database_name
  master_username                       = local.database_master_user_name
  master_password                       = aws_ssm_parameter.mysql_password.value
  iam_database_authentication_enabled   = true
  backup_retention_period               = 14
  preferred_backup_window               = "20:00-20:10"
  preferred_maintenance_window          = "sat:20:00-sat:21:00"
  database_insights_mode                = "standard"
  performance_insights_enabled          = true
  performance_insights_kms_key_id       = aws_kms_key.aurora.arn
  performance_insights_retention_period = 7
  db_subnet_group_name                  = aws_db_subnet_group.aurora.id
  db_cluster_parameter_group_name       = aws_rds_cluster_parameter_group.aurora.name
  backtrack_window                      = 86400
  final_snapshot_identifier             = "${local.project}-${local.env}-aurora-cluster-snapshot"
  deletion_protection                   = true
  storage_encrypted                     = true
  kms_key_id                            = aws_kms_key.aurora.arn
  enabled_cloudwatch_logs_exports       = local.enabled_cloudwatch_logs_exports
  apply_immediately                     = true

  iam_roles = [
    aws_iam_role.rds_iam_auth.arn,
    aws_iam_role.rds_performance_insights.arn,
  ]

  vpc_security_group_ids = [
    aws_security_group.aurora.id,
  ]

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      engine_version,
      database_name,
      master_username,
      master_password,
    ]
  }

  depends_on = [
    aws_kms_key.aurora,
    aws_ssm_parameter.mysql_password,
    aws_rds_cluster_parameter_group.aurora,
  ]

  tags = {
    Name     = "${local.project}-${local.env}-aurora-cluster"
    AutoStop = "true"
  }
}


# ===============================================================================
# Subnet Group
# ===============================================================================
resource "aws_db_subnet_group" "aurora" {
  name        = "${local.project}-${local.env}-aurora-cluster-subg"
  description = "Subnet group for ${local.project}-${local.env} Amazon Aurora Cluster"

  subnet_ids = [
    for subnet in aws_subnet.main_private :
    subnet.id
  ]

  tags = {
    Name = "${local.project}-${local.env}-aurora-cluster-subg"
  }
}


# ===============================================================================
# Amazon Aurora Instance
# ===============================================================================
resource "aws_rds_cluster_instance" "aurora" {
  count                                 = 2
  identifier                            = "${local.project}-${local.env}-aurora-instance-${count.index + 1}"
  cluster_identifier                    = aws_rds_cluster.aurora.id
  engine                                = aws_rds_cluster.aurora.engine
  engine_version                        = aws_rds_cluster.aurora.engine_version
  instance_class                        = "db.t4g.medium"
  db_subnet_group_name                  = aws_db_subnet_group.aurora.id
  db_parameter_group_name               = aws_db_parameter_group.aurora.name
  publicly_accessible                   = false
  auto_minor_version_upgrade            = true
  preferred_backup_window               = aws_rds_cluster.aurora.preferred_backup_window
  preferred_maintenance_window          = aws_rds_cluster.aurora.preferred_maintenance_window
  performance_insights_enabled          = true
  performance_insights_kms_key_id       = aws_kms_key.aurora.arn
  performance_insights_retention_period = 7
  ca_cert_identifier                    = "rds-ca-rsa2048-g1"
  promotion_tier                        = count.index
  apply_immediately                     = true
  force_destroy                         = true

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      engine_version,
    ]
  }

  depends_on = [
    aws_kms_key.aurora,
    aws_rds_cluster.aurora,
    aws_db_parameter_group.aurora,
  ]

  tags = {
    Name     = "${local.project}-${local.env}-aurora-instance-${count.index + 1}"
    AutoStop = "true"
  }
}


# ===============================================================================
# Cluster Parameter Group
# ===============================================================================
resource "aws_rds_cluster_parameter_group" "aurora" {
  name        = "${local.project}-${local.env}-aurora-cluster-dbpg"
  family      = "aurora-mysql8.0"
  description = "Amazon Aurora Cluster Parameter Group for ${local.project}-${local.env}"

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_database"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_connection"
    value = "utf8mb4"
  }

  parameter {
    name  = "general_log"
    value = 1
  }

  parameter {
    name  = "server_audit_logs_upload"
    value = 1
  }

  parameter {
    name  = "server_audit_logging"
    value = 1
  }

  parameter {
    name  = "server_audit_events"
    value = "connect,query_dcl,query_ddl,query_dml"
  }

  parameter {
    name  = "ssl_cipher"
    value = "ECDHE-RSA-AES256-GCM-SHA384"
  }

  parameter {
    name  = "time_zone"
    value = "Asia/Tokyo"
  }

  tags = {
    Name = "${local.project}-${local.env}-aurora-cluster-dbpg"
  }
}


# ===============================================================================
# DB Parameter Group
# ===============================================================================
resource "aws_db_parameter_group" "aurora" {
  name        = "${local.project}-${local.env}-aurora-instance-dbpg"
  family      = "aurora-mysql8.0"
  description = "Amazon Aurora DB Parameter Group for ${local.project}-${local.env}"

  parameter {
    name  = "max_connections"
    value = local.rds_max_connections
  }

  parameter {
    name  = "slow_query_log"
    value = 1
  }

  parameter {
    name  = "long_query_time"
    value = 0.1
  }

  parameter {
    name  = "log_output"
    value = "file"
  }

  parameter {
    name  = "general_log"
    value = 1
  }

  tags = {
    Name = "${local.project}-${local.env}-aurora-instance-dbpg"
  }
}
