# ================================================================================
# Amazon VPC
# ================================================================================
resource "aws_vpc" "main" {
  cidr_block                       = local.vpc_cidr_block
  enable_dns_hostnames             = true
  enable_dns_support               = true
  instance_tenancy                 = "default"
  assign_generated_ipv6_cidr_block = false

  tags = {
    Name = "${local.project}-${local.env}-vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.project}-${local.env}-igw"
  }
}

resource "aws_flow_log" "main_s3" {
  vpc_id               = aws_vpc.main.id
  log_destination      = aws_s3_bucket.vpc_flow_log.arn
  log_destination_type = "s3"
  traffic_type         = "ALL"

  destination_options {
    file_format        = "plain-text"
    per_hour_partition = true
  }

  tags = {
    Name = "${local.project}-${local.env}-vpc-flow-log"
  }
}


# ================================================================================
# Public Subnet
# ================================================================================
resource "aws_subnet" "main_public" {
  count                   = length(local.availability_zones)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 4, count.index)
  availability_zone       = local.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.project}-${local.env}-pubsub-${local.availability_zones[count.index]}"
  }
}

resource "aws_route_table" "main_public" {
  count  = length(local.availability_zones)
  vpc_id = aws_vpc.main.id

  lifecycle {
    ignore_changes = [
      route,
    ]
  }

  tags = {
    Name = "${local.project}-${local.env}-pubsub-rtb-${local.availability_zones[count.index]}"
  }
}

resource "aws_route" "main_public_to_default" {
  count                  = length(local.availability_zones)
  route_table_id         = aws_route_table.main_public[count.index].id
  destination_cidr_block = local.default_gateway_cidr
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "main_public" {
  count          = length(local.availability_zones)
  subnet_id      = aws_subnet.main_public[count.index].id
  route_table_id = aws_route_table.main_public[count.index].id
}


# ================================================================================
# Private Subnet
# ================================================================================
resource "aws_subnet" "main_private" {
  count                   = length(local.availability_zones)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 4, count.index + length(local.availability_zones))
  availability_zone       = local.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "${local.project}-${local.env}-privsub-${local.availability_zones[count.index]}"
  }
}

resource "aws_route_table" "main_private" {
  count  = length(local.availability_zones)
  vpc_id = aws_vpc.main.id

  lifecycle {
    ignore_changes = [
      route,
    ]
  }

  tags = {
    Name = "${local.project}-${local.env}-privsub-rtb-${local.availability_zones[count.index]}"
  }
}

resource "aws_route" "main_private_to_nat_gw" {
  count                  = length(local.availability_zones)
  route_table_id         = aws_route_table.main_private[count.index].id
  destination_cidr_block = local.default_gateway_cidr
  nat_gateway_id         = aws_nat_gateway.main[count.index].id
}

resource "aws_route_table_association" "main_private" {
  count          = length(local.availability_zones)
  subnet_id      = aws_subnet.main_private[count.index].id
  route_table_id = aws_route_table.main_private[count.index].id
}


# ================================================================================
# NAT Gateway
# ================================================================================
resource "aws_nat_gateway" "main" {
  count             = length(local.availability_zones)
  subnet_id         = aws_subnet.main_public[count.index].id
  allocation_id     = aws_eip.main[count.index].id
  connectivity_type = "public"

  tags = {
    Name = "${local.project}-${local.env}-ngw-${local.availability_zones[count.index]}"
  }
}


# ================================================================================
# EIP for NAT Gateway
# ================================================================================
resource "aws_eip" "main" {
  count  = length(local.availability_zones)
  domain = "vpc"

  lifecycle {
    prevent_destroy = false
  }

  tags = {
    Name = "${local.project}-${local.env}-ngw-eip-${local.availability_zones[count.index]}"
  }
}
