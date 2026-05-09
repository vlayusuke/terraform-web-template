# ===============================================================================
# Amazon EFS File System
# ===============================================================================
resource "aws_efs_file_system" "main" {
  region           = local.region
  creation_token   = "${local.project}-${local.env}-efs"
  encrypted        = true
  kms_key_id       = aws_kms_key.efs.arn
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"

  protection {
    replication_overwrite = "ENABLED"
  }

  tags = {
    Name = "${local.project}-${local.env}-efs"
  }
}

resource "aws_efs_access_point" "main" {
  region         = local.region
  file_system_id = aws_efs_file_system.main.id

  tags = {
    Name = "${local.project}-${local.env}-efs-access-point"
  }
}

resource "aws_efs_mount_target" "main_a" {
  region         = local.region
  file_system_id = aws_efs_file_system.main.id
  subnet_id      = aws_subnet.main_private[0].id

  security_groups = [
    aws_security_group.efs.id,
  ]

  lifecycle {
    ignore_changes = [
      security_groups,
    ]
  }
}

resource "aws_efs_mount_target" "main_c" {
  region         = local.region
  file_system_id = aws_efs_file_system.main.id
  subnet_id      = aws_subnet.main_private[1].id

  security_groups = [
    aws_security_group.efs.id,
  ]

  lifecycle {
    ignore_changes = [
      security_groups,
    ]
  }
}
