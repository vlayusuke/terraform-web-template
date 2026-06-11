# ===============================================================================
# VPC Endpoint (Amazon ECR - Docker)
# ===============================================================================
resource "aws_vpc_endpoint" "ecr_docker" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${local.region}.ecr.dkr"
  service_region      = local.region
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  security_group_ids = [
    aws_security_group.vpce_ecr.id,
  ]

  subnet_ids = [
    for subnet in aws_subnet.main_private :
    subnet.id
  ]

  tags = {
    Name = "${local.project}-${local.env}-vpce-ecr-dkr"
  }
}


# ===============================================================================
# VPC Endpoint (Amazon ECR - API)
# ===============================================================================
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${local.region}.ecr.api"
  service_region      = local.region
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  security_group_ids = [
    aws_security_group.vpce_ecr.id,
  ]

  subnet_ids = [
    for subnet in aws_subnet.main_private :
    subnet.id
  ]

  tags = {
    Name = "${local.project}-${local.env}-vpce-ecr-api"
  }
}


# ===============================================================================
# VPC Endpoint (AWS Systems Manager)
# ===============================================================================
resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${local.region}.ssm"
  service_region      = local.region
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  security_group_ids = [
    aws_security_group.vpce_ssm.id,
  ]

  subnet_ids = [
    for subnet in aws_subnet.main_private :
    subnet.id
  ]

  tags = {
    Name = "${local.project}-${local.env}-vpce-ssm"
  }
}


# ===============================================================================
# VPC Endpoint (AWS Systems Manager - Messages)
# ===============================================================================
resource "aws_vpc_endpoint" "ssm_messages" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${local.region}.ssmmessages"
  service_region      = local.region
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  security_group_ids = [
    aws_security_group.vpce_ssm.id,
  ]

  subnet_ids = [
    for subnet in aws_subnet.main_private :
    subnet.id
  ]

  tags = {
    Name = "${local.project}-${local.env}-vpce-ssm-messages"
  }
}


# ===============================================================================
# VPC Endpoint (Amazon EC2 - Messages)
# ===============================================================================
resource "aws_vpc_endpoint" "ec2_messages" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${local.region}.ec2messages"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  security_group_ids = [
    aws_security_group.vpce_ssm.id,
  ]

  subnet_ids = [
    for subnet in aws_subnet.main_private :
    subnet.id
  ]

  tags = {
    Name = "${local.project}-${local.env}-vpce-ec2-messages"
  }
}


# ===============================================================================
# VPC Endpoint (Amazon S3 Bucket)
# ===============================================================================
resource "aws_vpc_endpoint" "s3_gateway" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${local.region}.s3"
  vpc_endpoint_type = "Gateway"

  tags = {
    Name = "${local.project}-${local.env}-vpce-s3"
  }
}

resource "aws_vpc_endpoint_route_table_association" "s3_gateway" {
  count           = length(local.availability_zones)
  vpc_endpoint_id = aws_vpc_endpoint.s3_gateway.id
  route_table_id  = aws_route_table.main_private[count.index].id
}
