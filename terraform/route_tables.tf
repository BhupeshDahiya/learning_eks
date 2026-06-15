resource "aws_route_table" "pub" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${local.env}-pub-rt"
  }
}

resource "aws_route_table" "pvt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "${local.env}-pvt-rt"
  }
}

resource "aws_route_table_association" "pub_1" {
  subnet_id      = aws_subnet.pub_1.id
  route_table_id = aws_route_table.pub.id
}

resource "aws_route_table_association" "pub_2" {
  subnet_id      = aws_subnet.pub_2.id
  route_table_id = aws_route_table.pub.id
}

resource "aws_route_table_association" "pvt_1" {
  subnet_id      = aws_subnet.pvt_1.id
  route_table_id = aws_route_table.pvt.id
}

resource "aws_route_table_association" "pvt_2" {
  subnet_id      = aws_subnet.pvt_2.id
  route_table_id = aws_route_table.pvt.id
}