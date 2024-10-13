terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"

}

resource "aws_instance" "DevOps" {
  ami           = "ami-011899242bb902164"
  instance_type = "t2.micro"

  tags = {
    Name = "DevOps"
  }
}

#task