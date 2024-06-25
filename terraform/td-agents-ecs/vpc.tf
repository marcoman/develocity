resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    name = "main"
  }
}

resource "aws_subnet" "subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, 1)
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
}

resource "aws_subnet" "subnet2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, 2)
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.main.id
  tags = merge(
    local.common_tags,
    {
      "Name" = "internet-gateway"
    }
  )
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
}

resource "aws_route_table_association" "subnet_route" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_route_table_association" "subnet2_route" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_security_group" "security_group" {
  name   = "ecs-security-group"
  vpc_id = aws_vpc.main.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.security_group.id
  cidr_ipv4         = var.td-cidr-ingress
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "allow_egress" {
  security_group_id = aws_security_group.security_group.id
  cidr_ipv4         = var.td-cidr-egress
  ip_protocol       = "-1"
}
