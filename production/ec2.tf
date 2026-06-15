# ================================================================================
# Amazon EC2 Instance for Bastion
# ================================================================================
resource "aws_instance" "ec2_bastion" {
  ami                         = data.aws_ssm_parameter.arm64_al2023_ami.value
  instance_type               = "t4g.nano"
  key_name                    = aws_key_pair.ec2_bastion.key_name
  disable_api_stop            = false
  disable_api_termination     = false
  monitoring                  = true
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.main_public[0].id
  iam_instance_profile        = aws_iam_instance_profile.bastion.name

  vpc_security_group_ids = [
    aws_security_group.bastion.id,
  ]

  user_data = templatefile(
    "files/startup_scripts/bastion.sh",
    {
      bastion_bucket = aws_s3_bucket.bastion.id
    },
    "files/startup_scripts/awslogs.conf",
    {
      bastion_bucket = aws_s3_bucket.bastion.id
      log_group_name = aws_cloudwatch_log_group.bastion.name
      instance_id    = aws_instance.ec2_bastion.id
    }
  )

  credit_specification {
    cpu_credits = "standard"
  }

  root_block_device {
    volume_size = "8"
    volume_type = "gp3"
    encrypted   = true
    kms_key_id  = aws_kms_key.ebs.arn

    tags = {
      Name   = "${local.project}-${local.env}-ec2-bastion-root-volume"
      Backup = "true"
    }
  }

  ebs_block_device {
    device_name = "/dev/xvdf"
    volume_size = "64"
    volume_type = "gp3"
    encrypted   = true
    kms_key_id  = aws_kms_key.ebs.arn

    tags = {
      Name   = "${local.project}-${local.env}-ec2-bastion-ebs-volume"
      Backup = "true"
    }
  }

  lifecycle {
    ignore_changes = [
      ami,
    ]
  }

  tags = {
    Name   = "${local.project}-${local.env}-ec2-bastion"
    Backup = "true"
  }
}


# ================================================================================
# EIP for Amazon EC2 Instance (Bastion)
# ================================================================================
resource "aws_eip" "ec2_bastion" {
  instance = aws_instance.ec2_bastion.id
  domain   = "vpc"

  lifecycle {
    prevent_destroy = false
  }

  tags = {
    Name = "${local.project}-${local.env}-ec2-bastion-eip"
  }
}


# ================================================================================
# Key Pair for Amazon EC2 Instance (Bastion)
# ================================================================================
resource "aws_key_pair" "ec2_bastion" {
  key_name   = "${local.project}-${local.env}-ec2-bastion-key"
  public_key = var.aws_key_pub_bastion

  tags = {
    Name = "${local.project}-${local.env}-ec2-bastion-key"
  }
}


# ================================================================================
# AWS SSM Parameter for Amazon EC2 Instance (Bastion) AMI IDs
# ================================================================================
data "aws_ssm_parameter" "arm64_al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-arm64"
}

data "aws_ssm_parameter" "x86_64_al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}


# If you want to use Amazon EC2 Instance Connect Endpoint, uncomment the following code and run `terraform apply` after creating the EC2 instance for Bastion. Note that you need to create a security group for EC2 Instance Connect Endpoint before applying the changes.
# ================================================================================
# Amazon EC2 Instance Connect Endpoint
# ================================================================================
# resource "aws_ec2_instance_connect_endpoint" "eic_endpoint_a" {
#   ip_address_type = "ipv4"
#   subnet_id       = aws_subnet.main_private[0].id
#
#   depends_on = [
#     aws_security_group.eic,
#   ]
#
#   tags = {
#     Name = "${local.project}-${local.env}-eic-endpoint-a"
#   }
# }
#
# resource "aws_ec2_instance_connect_endpoint" "eic_endpoint_c" {
#   ip_address_type = "ipv4"
#   subnet_id       = aws_subnet.main_private[1].id
#
#   depends_on = [
#     aws_security_group.eic,
#   ]
#
#   tags = {
#     Name = "${local.project}-${local.env}-eic-endpoint-c"
#   }
# }
