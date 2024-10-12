terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Define el backend para almacenar el estado de Terraform
  backend "s3" {
    bucket  = "my-terraform-state-bucket" # Verifica que este bucket exista
    key     = "terraform/state"
    region  = "us-east-1"
    encrypt = true
  }
}

provider "aws" {
  region = "us-east-1"
}

# Crear la VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "MainVPC"
  }
}

# Crear el Subnet asociado a la VPC
resource "aws_subnet" "web_server" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "WebServerSubnet"
  }
}

# Crear el Security Group para la instancia
resource "aws_security_group" "web_server" {
  name        = "web_server_sg"
  description = "Security group for web server"
  vpc_id      = aws_vpc.main.id

  # Permitir tráfico de entrada por SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Permitir tráfico de entrada por HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Permitir todo el tráfico de salida
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Crear la interfaz de red para la instancia
resource "aws_network_interface" "web_server" {
  subnet_id       = aws_subnet.web_server.id
  security_groups = [aws_security_group.web_server.id]

  tags = {
    Name = "WebServerNetworkInterface"
  }
}

# Crear la instancia EC2 y asociarla a la interfaz de red
resource "aws_instance" "web_server" {
  ami           = "ami-011899242bb902164" # Ubuntu 20.04 LTS
  instance_type = "t2.micro"

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.web_server.id
  }

  # Archivo de configuración de usuario para inicializar la instancia
  user_data = file("setup.sh")

  tags = {
    Name = "WebServerInstance"
  }

  depends_on = [aws_network_interface.web_server]
}
