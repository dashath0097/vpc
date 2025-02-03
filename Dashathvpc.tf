provider "aws" {
  region     = "us-east-1" 
}

# VPC
resource "aws_vpc" "vpc1" {
  cidr_block              = "192.168.0.0/16"
  enable_dns_support      = true
  enable_dns_hostnames    = true
}

# Public Subnet
resource "aws_subnet" "pub" {
  vpc_id                  = aws_vpc.vpc1.id
  map_public_ip_on_launch = true
  cidr_block              = "192.168.1.0/24"
}

# Private Subnet
resource "aws_subnet" "pri" {
  vpc_id                  = aws_vpc.vpc1.id
  map_public_ip_on_launch = false
  cidr_block              = "192.168.2.0/24"
}

# Internet Gateway
resource "aws_internet_gateway" "hathway" {
  vpc_id = aws_vpc.vpc1.id
}

# Public Route Table
resource "aws_route_table" "myrout" {
  vpc_id = aws_vpc.vpc1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.hathway.id
  }
}

# Associate Public Route Table with Public Subnet
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.pub.id
  route_table_id = aws_route_table.myrout.id
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat_eip" {
  vpc = true
}

# NAT Gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.pub.id
}

# Private Route Table
resource "aws_route_table" "private_routetable" {
  vpc_id = aws_vpc.vpc1.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
}

# Associate Private Route Table with Private Subnet
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.pri.id
  route_table_id = aws_route_table.private_routetable.id
}

# Public Instance
resource "aws_instance" "public" {
  ami           = "ami-0453ec754f44f9a4a"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.pub.id
}

# Private Instance
resource "aws_instance" "private" {
  ami           = "ami-0453ec754f44f9a4a"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.pri.id
}
