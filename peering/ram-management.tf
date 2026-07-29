########################
# VPC: ram-management-vpc
########################

resource "aws_vpc" "ram_mgmt" {
  cidr_block           = "10.20.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "ram-management-vpc"
  }
}

########################
# Public Subnets (management VPC)
########################

resource "aws_subnet" "ram_mgmt_public_a" {
  vpc_id                  = aws_vpc.ram_mgmt.id
  cidr_block              = "10.20.1.0/24"
  availability_zone       = "us-west-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "ram-mgmt-public-a"
    Tier = "public"
  }
}

resource "aws_subnet" "ram_mgmt_public_b" {
  vpc_id                  = aws_vpc.ram_mgmt.id
  cidr_block              = "10.20.2.0/24"
  availability_zone       = "us-west-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "ram-mgmt-public-b"
    Tier = "public"
  }
}

########################
# Internet Gateway
########################

resource "aws_internet_gateway" "ram_mgmt_igw" {
  vpc_id = aws_vpc.ram_mgmt.id

  tags = {
    Name = "ram-mgmt-igw"
  }
}

########################
# Route Table (Public)
########################

resource "aws_route_table" "ram_mgmt_public_rt" {
  vpc_id = aws_vpc.ram_mgmt.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ram_mgmt_igw.id
  }

  tags = {
    Name = "ram-mgmt-public-rt"
    Tier = "public"
  }
}

resource "aws_route_table_association" "ram_mgmt_public_a_assoc" {
  subnet_id      = aws_subnet.ram_mgmt_public_a.id
  route_table_id = aws_route_table.ram_mgmt_public_rt.id
}

resource "aws_route_table_association" "ram_mgmt_public_b_assoc" {
  subnet_id      = aws_subnet.ram_mgmt_public_b.id
  route_table_id = aws_route_table.ram_mgmt_public_rt.id
}

########################
# Network ACL (Public)
########################

resource "aws_network_acl" "ram_mgmt_nacl" {
  vpc_id = aws_vpc.ram_mgmt.id

  subnet_ids = [
    aws_subnet.ram_mgmt_public_a.id,
    aws_subnet.ram_mgmt_public_b.id
  ]

  # Ingress - allow all
  ingress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  # Egress - allow all
  egress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "ram-mgmt-nacl"
    Tier = "public"
  }
}

########################
# Security Group
########################

resource "aws_security_group" "ram_mgmt_sg" {
  name        = "ram-mgmt-sg"
  description = "Management VPC SG"
  vpc_id      = aws_vpc.ram_mgmt.id

  # SSH
  ingress {
    description = "SSH allow"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP
  ingress {
    description = "HTTP allow"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS
  ingress {
    description = "HTTPS allow"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress all
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ram-mgmt-sg"
    Tier = "public"
  }
}
