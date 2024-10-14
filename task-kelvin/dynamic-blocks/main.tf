
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "MainVPC"
  }
}

resource "aws_subnet" "web_server" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "WebServerSubnet911"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "MainInternetGateway"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "PublicRouteTable"
  }
}

resource "aws_route_table_association" "web_subnet" {
  subnet_id      = aws_subnet.web_server.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "myweb" {
  name        = "myweb"
  description = "Permite acceso HTTP, HTTPS y SSH"
  vpc_id      = aws_vpc.main.id

  dynamic "ingress" {
    for_each = local.ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = local.egress_rules
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }

  tags = {
    Name = "WebServerSG911"
  }
}

resource "aws_instance" "web_server" {
  ami           = "ami-011899242bb902164"
  instance_type = "t2.micro"

  subnet_id              = aws_subnet.web_server.id
  vpc_security_group_ids = [aws_security_group.myweb.id]

  associate_public_ip_address = true

  tags = {
    Name = "WebServerInstance911"
  }

  depends_on = [
    aws_internet_gateway.igw,
    aws_route_table_association.web_subnet
  ]
}
