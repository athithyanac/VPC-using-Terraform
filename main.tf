#creating vpc
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
#creating public subnets
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
#creating igw
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = var.project
    project = var.project
  }
}
#creating public rtb
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
#creating public rtb association
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
#creating private subnets
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
#creating private rtb association
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
#creating nat-gw
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
/*
#creating key
resource "aws_key_pair" "mykey" {
  key_name   = "zomato"
  public_key = file("mykey.pub")

  tags = {
    Name = var.project
    project = var.project
  }
}
# SG for bastion
resource "aws_security_group" "bastion" {
  name        = "bastion"
  description = "Allow 22 from all"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = var.project
    project = var.project
  }
}
# SG for front end
resource "aws_security_group" "frontend" {
  name        = "frontend"
  description = "Allow 22 from bastion and 80 from all"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    security_groups  = [aws_security_group.bastion.id]
  }
  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = var.project
    project = var.project
  }
}
# SG for back end
resource "aws_security_group" "backend" {
  name        = "backend"
  description = "Allow 22 and 3306 from bastion"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    security_groups  = [aws_security_group.bastion.id]
  }
  ingress {
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    security_groups  = [aws_security_group.bastion.id]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = var.project
    project = var.project
  }
}
#creating ec2 bastion
resource "aws_instance" "bastion" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = aws_key_pair.mykey.id
  vpc_security_group_ids = [aws_security_group.bastion.id]
  subnet_id              = aws_subnet.public1.id

  tags = {
    Name = "bastion"
    project = var.project
  }
}
#creating ec2 frontend
resource "aws_instance" "frontend" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = aws_key_pair.mykey.id
  vpc_security_group_ids = [aws_security_group.frontend.id]
  user_data              = file("frontend.sh")
  subnet_id              = aws_subnet.public1.id

  tags = {
    Name = "frontend"
    project = var.project
  }
}
#creating ec2 backend
resource "aws_instance" "backend" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = aws_key_pair.mykey.id
  vpc_security_group_ids = [aws_security_group.backend.id]
  user_data              = file("backend.sh")
  subnet_id              = aws_subnet.private1.id

  tags = {
    Name = "backend"
    project = var.project
  }
}*/