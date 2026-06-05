data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs = data.aws_availability_zones.available.names
  
  common_tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = merge(local.common_tags, { Name = var.vpc_name })
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = merge(local.common_tags, { Name = "${var.vpc_name}-igw" })
}

resource "aws_subnet" "public" {
  count                   = var.public_subnet_count
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone       = local.azs[count.index % length(local.azs)]
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, { 
    Name = "${var.vpc_name}-public-subnet-${count.index + 1}"
    Type = "public"
  })
}

resource "aws_subnet" "private" {
  count             = var.private_subnet_count
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + var.public_subnet_count)
  availability_zone = local.azs[count.index % length(local.azs)]

  tags = merge(local.common_tags, { 
    Name = "${var.vpc_name}-private-subnet-${count.index + 1}"
    Type = "private"
  })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = merge(local.common_tags, { Name = "${var.vpc_name}-public-rt" })
}

resource "aws_route_table_association" "public" {
  count          = var.public_subnet_count
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  count  = var.private_subnet_count
  vpc_id = aws_vpc.main.id
  tags   = merge(local.common_tags, { Name = "${var.vpc_name}-private-rt-${count.index + 1}" })
}

resource "aws_route_table_association" "private" {
  count          = var.private_subnet_count
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}