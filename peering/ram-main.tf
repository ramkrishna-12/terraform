########################
# VPC: ram-main-vpc
########################

resource "aws_vpc" "ram_main" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "ram-main-vpc"
  }
}

########################
# Subnets (main VPC)
########################

# Public subnets
resource "aws_subnet" "ram_main_public_a" {
  vpc_id                  = aws_vpc.ram_main.id
  cidr_block              = "10.10.1.0/24"
  availability_zone       = "us-west-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "ram-main-public-a"
    Tier = "public"
  }
}

resource "aws_subnet" "ram_main_public_b" {
  vpc_id                  = aws_vpc.ram_main.id
  cidr_block              = "10.10.2.0/24"
  availability_zone       = "us-west-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "ram-main-public-b"
    Tier = "public"
  }
}

# Private subnets
resource "aws_subnet" "ram_main_private_a" {
  vpc_id                  = aws_vpc.ram_main.id
  cidr_block              = "10.10.3.0/24"
  availability_zone       = "us-west-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "ram-main-private-a"
    Tier = "private"
  }
}

resource "aws_subnet" "ram_main_private_b" {
  vpc_id                  = aws_vpc.ram_main.id
  cidr_block              = "10.10.4.0/24"
  availability_zone       = "us-west-1b"
  map_public_ip_on_launch = false

  tags = {
    Name = "ram-main-private-b"
    Tier = "private"
  }
}

########################
# IGW (main VPC)
########################

resource "aws_internet_gateway" "ram_main_igw" {
  vpc_id = aws_vpc.ram_main.id

  tags = {
    Name = "ram-main-igw"
  }
}

########################
# Public Route Table
########################

resource "aws_route_table" "ram_main_public_rt" {
  vpc_id = aws_vpc.ram_main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ram_main_igw.id
  }

  tags = {
    Name = "ram-main-public-rt"
    Tier = "public"
  }
}

resource "aws_route_table_association" "ram_main_public_a_assoc" {
  subnet_id      = aws_subnet.ram_main_public_a.id
  route_table_id = aws_route_table.ram_main_public_rt.id
}

resource "aws_route_table_association" "ram_main_public_b_assoc" {
  subnet_id      = aws_subnet.ram_main_public_b.id
  route_table_id = aws_route_table.ram_main_public_rt.id
}

########################
# Private Subnets: No Internet Route Yet
########################

# They stay isolated purposely until NAT/EIP quota upgrade

########################
# NACLs
########################

# Public NACL
resource "aws_network_acl" "ram_main_public_nacl" {
  vpc_id = aws_vpc.ram_main.id

  subnet_ids = [
    aws_subnet.ram_main_public_a.id,
    aws_subnet.ram_main_public_b.id
  ]

  ingress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "ram-main-public-nacl"
    Tier = "public"
  }
}

# Private NACL (Fully open for now)
resource "aws_network_acl" "ram_main_private_nacl" {
  vpc_id = aws_vpc.ram_main.id

  subnet_ids = [
    aws_subnet.ram_main_private_a.id,
    aws_subnet.ram_main_private_b.id
  ]

  ingress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = "10.10.0.0/16"
    from_port  = 0
    to_port    = 0
  }

  egress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = "10.10.0.0/16"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "ram-main-private-nacl"
    Tier = "private"
  }
}

########################
# Security Group
########################

resource "aws_security_group" "ram_main_sg" {
  name        = "ram-main-sg"
  description = "Main VPC SG"
  vpc_id      = aws_vpc.ram_main.id

  ingress {
    description = "SSH allow"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP allow"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS allow"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ram-main-sg"
    Tier = "public"
  }
}
