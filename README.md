# VPC using Terraform

### Creating VPC

resource "aws_vpc" "vpc" {

  cidr_block       = var.vpc_cidr
  
  instance_tenancy = "default"
  
  enable_dns_support = "true"
  
  enable_dns_hostnames = "true"

  tags = {

    Name = var.project
    project = var.project
  }
  
}

### Creating public subnets
resource "aws_subnet" "public1" {

  vpc_id     = aws_vpc.vpc.id
  
  cidr_block = cidrsubnet(var.vpc_cidr, var.newbits, 0)
  
  availability_zone = data.aws_availability_zones.azs.names[0] 
  
  map_public_ip_on_launch = "true"

 tags = {
 
    Name = "${var.project}-public1"
    project = var.project
  }
  
}
resource "aws_subnet" "public2" {

  vpc_id     = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr, var.newbits, 1)
  
  availability_zone = data.aws_availability_zones.azs.names[1] 
  
  map_public_ip_on_launch = "true"

  tags = {
  
    Name = "${var.project}-public2"
    project = var.project
  }
}
resource "aws_subnet" "public3" {

  vpc_id     = aws_vpc.vpc.id
  
  cidr_block = cidrsubnet(var.vpc_cidr, var.newbits, 2)
  
  availability_zone = data.aws_availability_zones.azs.names[2] 
  
  map_public_ip_on_launch = "true"

  tags = {
  
    Name = "${var.project}-public3"
    project = var.project
  }
  
}

### Creating igw
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
  
    Name = var.project
    project = var.project
  }
}
### Creating public rtb
resource "aws_route_table" "public_rtb" {

  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  
  tags = {
  
    Name = "${var.project}-public"
    project = var.project
  }
}
### creating public rtb association
resource "aws_route_table_association" "public1" {

  subnet_id      = aws_subnet.public1.id
  
  route_table_id = aws_route_table.public_rtb.id
}

resource "aws_route_table_association" "public2" {

  subnet_id      = aws_subnet.public2.id
  
  route_table_id = aws_route_table.public_rtb.id
}

resource "aws_route_table_association" "public3" {

  subnet_id      = aws_subnet.public3.id
  
  route_table_id = aws_route_table.public_rtb.id
}

### creating private subnets
resource "aws_subnet" "private1" {

  vpc_id     = aws_vpc.vpc.id
  
  cidr_block = cidrsubnet(var.vpc_cidr, var.newbits, 3)
  
  availability_zone = data.aws_availability_zones.azs.names[0]
  
 tags = {
 
    Name = "${var.project}-private1"
    project = var.project
  }
  
}
resource "aws_subnet" "private2" {

  vpc_id     = aws_vpc.vpc.id
  
  cidr_block = cidrsubnet(var.vpc_cidr, var.newbits, 4)
  
  availability_zone = data.aws_availability_zones.azs.names[1] 
  
 tags = {
 
    Name = "${var.project}-private2"
    project = var.project
  }
  
}
resource "aws_subnet" "private3" {

  vpc_id     = aws_vpc.vpc.id
  
  cidr_block = cidrsubnet(var.vpc_cidr, var.newbits, 5)
  
  availability_zone = data.aws_availability_zones.azs.names[2] 
  
 tags = {
 
    Name = "${var.project}-private3"
    project = var.project
  }
  
}

#creating private rtb
resource "aws_route_table" "private_rtb" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw.id
  }
  tags = {
  
    Name = "${var.project}-private"
    project = var.project
  }
}
#### creating private rtb association
resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private_rtb.id
}
resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private_rtb.id
}
resource "aws_route_table_association" "private3" {
  subnet_id      = aws_subnet.private3.id
  route_table_id = aws_route_table.private_rtb.id
}
### creating nat-gw
resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public1.id

  tags = {
  
    Name = var.project
    project = var.project
  }
  depends_on = [aws_internet_gateway.igw]
}
#creating elastic ip
resource "aws_eip" "eip" {
  vpc = true

  tags = {
  
    Name = var.project
    project = var.project
  }
}
