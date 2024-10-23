# Datos remotos para obtener información de la VPC
data "aws_vpc" "selected" {
  id = var.vpc_id
}

# Módulo local para reglas de seguridad
module "security_rules" {
  source = "./modules/security_rules"
}

# Datos remotos para AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}