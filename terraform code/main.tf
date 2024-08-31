terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Define el backend para almacenar el estado de Terraform
  backend "s3" {
    bucket         = "my-terraform-state-bucket"
    key            = "terraform/state"
    region         = "us-east-1"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "web_server" {
  ami           = "ami-011899242bb902164"  # Ubuntu 20.04 LTS
  instance_type = "t2.micro"

  tags = {
    Name = "WebServerInstance"
  }

  # Configuración de red y seguridad
  network_interface {
    device_index          = 0
    network_interface_id  = aws_network_interface.web_server.id
  }

  # Archivo de configuración de usuario para inicializar la instancia
  user_data = file("setup.sh")
}

resource "aws_network_interface" "web_server" {
  subnet_id       = aws_subnet.web_server.id
  security_groups = [aws_security_group.web_server.id]

  tags = {
    Name = "WebServerNetworkInterface"
  }
}

resource "aws_security_group" "web_server" {
  name        = "web_server_sg"
  description = "Security group for web server"

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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_subnet" "web_server" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "WebServerSubnet"
  }
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "MainVPC"
  }
}
