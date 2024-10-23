terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket  = "my-terraform-state-bucket911"
    key     = "terraform/state"
    region  = "us-east-1"
    encrypt = true
  }
}

provider "aws" {
  region = "us-east-1"
}


resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "MainVPC"
  }
}


resource "aws_subnet" "web_server" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"


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


resource "aws_security_group" "web_server" {
  name        = "web_server_sg"
  description = "Security group for web server"
  vpc_id      = aws_vpc.main.id


  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
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
    Name = "WebServerSG911"
  }
}


resource "aws_instance" "web_server" {
  ami           = "ami-011899242bb902164"
  instance_type = "t2.micro"


  subnet_id              = aws_subnet.web_server.id
  vpc_security_group_ids = [aws_security_group.web_server.id]


  associate_public_ip_address = true

  tags = {
    Name = "WebServerInstance911"
  }


  depends_on = [aws_internet_gateway.igw, aws_route_table_association.web_subnet]
}
#task