# ===============================================================================
# Security Group for Application Load Balancer
# ===============================================================================
resource "aws_security_group" "alb_external" {
  name        = "${local.project}-${local.env}-sgr-alb-external"
  description = "Security Group for ${local.project}-${local.env} External ALB"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      local.default_gateway_cidr,
    ]
  }

  tags = {
    Name = "${local.project}-${local.env}-sgr-alb-external"
  }
}

resource "aws_security_group_rule" "ingress_from_cloudfront_sg_rule" {
  description       = "Allow HTTPS traffic from CloudFront Managed Prefix List"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.alb_external.id

  cidr_blocks = [
    for natgw_eip in aws_eip.main : "${natgw_eip.public_ip}/32"
  ]

  prefix_list_ids = [
    data.aws_ec2_managed_prefix_list.cloudfront.id,
  ]
}

data "aws_ec2_managed_prefix_list" "cloudfront" {
  id   = "pl-58a04531"
  name = "com.amazonaws.global.cloudfront.origin-facing"
}


# ===============================================================================
# Security Group for VPC Endpoint (Amazon ECR - Docker)
# ===============================================================================
resource "aws_security_group" "vpce_ecr" {
  name        = "${local.project}-${local.env}-sgr-vpce-ecr"
  description = "Security Group for Amazon ECR VPC EndPoint"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow HTTPS traffic from AWS Fargate Security Groups"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_groups = [
      aws_security_group.fargate_app.id,
      aws_security_group.fargate_cron.id,
      aws_security_group.fargate_queue.id,
    ]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      local.default_gateway_cidr,
    ]
  }

  tags = {
    Name = "${local.project}-${local.env}-sgr-vpce-ecr"
  }
}


# ===============================================================================
# Security Group for VPC Endpoint (AWS Systems Manager)
# ===============================================================================
resource "aws_security_group" "vpce_ssm" {
  name        = "${local.project}-${local.env}-sgr-vpce-ssm"
  description = "Security Group for AWS Systems Manager VPC EndPoint"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow HTTPS traffic from VPC Security Group"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [
      aws_vpc.main.cidr_block,
    ]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      local.default_gateway_cidr,
    ]
  }

  tags = {
    Name = "${local.project}-${local.env}-sgr-vpce-ssm"
  }
}


# ===============================================================================
# Security Group for VPC Endpoint (Amazon SNS)
# ===============================================================================
resource "aws_security_group" "vpce_sns" {
  name        = "${local.project}-${local.env}-sgr-vpce-sns"
  description = "Security Group for Amazon SNS VPC EndPoint"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow HTTPS traffic from VPC Security Group"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [
      aws_vpc.main.cidr_block,
    ]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      local.default_gateway_cidr,
    ]
  }

  tags = {
    Name = "${local.project}-${local.env}-sgr-vpce-sns"
  }
}


# ===============================================================================
# Security Group for AWS Fargate (app)
# ===============================================================================
resource "aws_security_group" "fargate_app" {
  name        = "${local.project}-${local.env}-sgr-fargate-app"
  description = "Security Group for ${local.project}-${local.env} AWS Fargate app"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow HTTP traffic from ALB Security Group"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [
      aws_security_group.alb_external.id,
    ]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      local.default_gateway_cidr,
    ]
  }

  tags = {
    Name = "${local.project}-${local.env}-sgr-fargate-app"
  }
}


# ===============================================================================
# Security Group for AWS Fargate (cron)
# ===============================================================================
resource "aws_security_group" "fargate_cron" {
  name        = "${local.project}-${local.env}-sgr-fargate-cron"
  description = "Security Group for ${local.project}-${local.env} AWS Fargate cron"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow HTTP traffic from AWS Fargate app Security Group"
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    security_groups = [
      aws_security_group.fargate_app.id,
    ]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      local.default_gateway_cidr,
    ]
  }

  tags = {
    Name = "${local.project}-${local.env}-sgr-fargate-cron"
  }
}


# ===============================================================================
# Security Group for AWS Fargate (queue)
# ===============================================================================
resource "aws_security_group" "fargate_queue" {
  name        = "${local.project}-${local.env}-sgr-fargate-queue"
  description = "Security Group for ${local.project}-${local.env} AWS Fargate queue"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow HTTP traffic from AWS Fargate app Security Group"
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    security_groups = [
      aws_security_group.fargate_app.id,
    ]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      local.default_gateway_cidr,
    ]
  }

  tags = {
    Name = "${local.project}-${local.env}-sgr-fargate-queue"
  }
}


# ===============================================================================
# Security Group for Amazon Aurora
# ===============================================================================
resource "aws_security_group" "aurora" {
  name        = "${local.project}-${local.env}-sgr-aur"
  description = "Security Group for ${local.project}-${local.env} Amazon Aurora"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow MySQL traffic from AWS Fargate app Security Group"
    protocol    = "tcp"
    from_port   = 3306
    to_port     = 3306
    security_groups = [
      aws_security_group.fargate_app.id,
    ]
  }

  ingress {
    description = "Allow MySQL traffic from AWS Fargate cron Security Group"
    protocol    = "tcp"
    from_port   = 3306
    to_port     = 3306
    security_groups = [
      aws_security_group.fargate_cron.id,
    ]
  }

  ingress {
    description = "Allow MySQL traffic from AWS Fargate queue Security Group"
    protocol    = "tcp"
    from_port   = 3306
    to_port     = 3306
    security_groups = [
      aws_security_group.fargate_queue.id,
    ]
  }

  ingress {
    description = "Allow MySQL traffic from Amazon EC2 Bastion Instance Security Group"
    protocol    = "tcp"
    from_port   = 3306
    to_port     = 3306
    security_groups = [
      aws_security_group.bastion.id,
    ]
  }

  ingress {
    description = "Allow SSH traffic from Amazon EC2 Bastion Instance Security Group"
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    security_groups = [
      aws_security_group.bastion.id,
    ]
  }

  ingress {
    description = "Allow MySQL traffic from Amazon EC2 Instance Connector Endpoint Security Group"
    protocol    = "tcp"
    from_port   = 3306
    to_port     = 3306
    security_groups = [
      aws_security_group.eic.id,
    ]
  }

  ingress {
    description = "Allow SSH traffic from Amazon EC2 Instance Connector Endpoint Security Group"
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    security_groups = [
      aws_security_group.eic.id,
    ]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      local.default_gateway_cidr,
    ]
  }

  tags = {
    Name = "${local.project}-${local.env}-sgr-aur"
  }
}


# ===============================================================================
# Security Group for Amazon ElastiCache
# ===============================================================================
resource "aws_security_group" "redis" {
  name        = "${local.project}-${local.env}-sgr-elc"
  description = "Security Group for ${local.project}-${local.env} Amazon ElastiCache"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow Redis traffic from AWS Fargate app Security Group"
    protocol    = "tcp"
    from_port   = 6379
    to_port     = 6379
    security_groups = [
      aws_security_group.fargate_app.id,
    ]
  }

  ingress {
    description = "Allow Redis traffic from AWS Fargate cron Security Group"
    protocol    = "tcp"
    from_port   = 6379
    to_port     = 6379
    security_groups = [
      aws_security_group.fargate_cron.id,
    ]
  }

  ingress {
    description = "Allow Redis traffic from AWS Fargate queue Security Group"
    protocol    = "tcp"
    from_port   = 6379
    to_port     = 6379
    security_groups = [
      aws_security_group.fargate_queue.id,
    ]
  }

  ingress {
    description = "Allow Redis traffic from Amazon EC2 Bastion Instance Security Group"
    protocol    = "tcp"
    from_port   = 6379
    to_port     = 6379
    security_groups = [
      aws_security_group.bastion.id,
    ]
  }

  ingress {
    description = "Allow Redis traffic from Amazon EC2 Instance Connector Endpoint Security Group"
    protocol    = "tcp"
    from_port   = 6379
    to_port     = 6379
    security_groups = [
      aws_security_group.eic.id,
    ]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      local.default_gateway_cidr,
    ]
  }

  tags = {
    Name = "${local.project}-${local.env}-sgr-elc"
  }
}


# ===============================================================================
# Security Group for Amazon EFS
# ===============================================================================
resource "aws_security_group" "efs" {
  name        = "${local.project}-${local.env}-sgr-efs"
  description = "Security Group for ${local.project}-${local.env} Amazon EFS"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow NFS traffic from AWS Fargate app Security Group"
    protocol    = "tcp"
    from_port   = 2049
    to_port     = 2049
    security_groups = [
      aws_security_group.fargate_app.id,
    ]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      local.default_gateway_cidr,
    ]
  }

  tags = {
    Name = "${local.project}-${local.env}-sgr-efs"
  }
}


# ================================================================================
# Security Group for Amazon EC2 Bastion
# ================================================================================
resource "aws_security_group" "bastion" {
  name        = "${local.project}-${local.env}-sgr-ec2-bastion"
  description = "Security Group for ${local.project}-${local.env} Amazon EC2 Bastion"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow SSH traffic from Maintenance IPs"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [
      for ip in var.maintenance_ips :
      ip
    ]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      local.default_gateway_cidr,
    ]
  }

  tags = {
    Name = "${local.project}-${local.env}-sgr-ec2-bastion"
  }
}


# ================================================================================
# Security Group for EC2 Instance Connector Endpoint
# ================================================================================
resource "aws_security_group" "eic" {
  name        = "${local.project}-${local.env}-sgr-eic"
  description = "Security Group for ${local.project}-${local.env} EC2 Instance Connector Endpoint"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow SSH traffic from Maintenance IPs"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [
      for ip in var.maintenance_ips :
      ip
    ]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      local.default_gateway_cidr,
    ]
  }

  tags = {
    Name = "${local.project}-${local.env}-sgr-eic"
  }
}
