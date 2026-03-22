resource "aws_vpc" "my_lb_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "my_lb_vpc"
  }
}

resource "aws_subnet" "my_lb_public_subnet_1" {
  cidr_block = var.public_subnet_1
  vpc_id = aws_vpc.my_lb_vpc.id
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "my_lb_public_subnet_1"
  }
}

resource "aws_subnet" "my_lb_public_subnet_2" {
  cidr_block = var.public_subnet_2
  vpc_id = aws_vpc.my_lb_vpc.id
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "my_lb_public_subnet_2"
  }
}


resource "aws_internet_gateway" "my_lb_igw" {
  vpc_id = aws_vpc.my_lb_vpc.id 
}

resource "aws_route_table" "my_lb_rt" {
  vpc_id = aws_vpc.my_lb_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_lb_igw.id
  }
}

resource "aws_route_table_association" "my_lb_rt_public_1" {
  subnet_id = aws_subnet.my_lb_public_subnet_1.id
  route_table_id = aws_route_table.my_lb_rt.id
}


resource "aws_route_table_association" "my_lb_rt_public_2" {
  subnet_id = aws_subnet.my_lb_public_subnet_2.id
  route_table_id = aws_route_table.my_lb_rt.id
}
