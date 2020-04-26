locals {
  vpc_cidr_block = "10.0.0.0/16"
  az_cidrs = {
    az1 = "10.0.0.0/24"
    az2 = "10.0.1.0/24"
  }
}

resource "aws_vpc" "main" {
  cidr_block           = local.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "standalone-server-vpc"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.main.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

resource "aws_subnet" "public" {
  count                   = 2
  cidr_block              = cidrsubnet(local.az_cidrs["az${count.index + 1}"], 2, 2)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = true
  tags = {
    Name       = "public-${data.aws_availability_zones.available.names[count.index]}"
    SubnetType = "public"
  }
}
