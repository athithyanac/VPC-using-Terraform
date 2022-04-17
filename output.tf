output "Public_Subnets" {
    value = [ aws_subnet.public1,aws_subnet.public2,aws_subnet.public3 ]
}
output "Private_Subnets" {
    value = [ aws_subnet.private1,aws_subnet.private2,aws_subnet.private3 ]
}
output "Availability_Zones" {
  value = [ data.aws_availability_zones.azs.names[0], data.aws_availability_zones.azs.names[1],
  data.aws_availability_zones.azs.names[2] ]
}
output "aws_eip" {
  value = aws_eip.eip.public_ip
}
output "aws_vpc" {
  value = aws_vpc.vpc.id
}
output "aws_internet_gateway" {
  value = aws_internet_gateway.igw.id
}
output "aws_nat_gateway" {
  value = aws_nat_gateway.natgw.id
}
output "aws_route_table_public" {
value = aws_route_table.public_rtb.id
}
output "aws_route_table_private" {
  value = aws_route_table.private_rtb.id
}

