# Grupo de seguridad mejorado
resource "aws_security_group" "myweb" {
  provider    = aws.primary
  name        = "myweb-${terraform.workspace}"
  description = "Permite el acceso con reglas dinámicas y locales"
  vpc_id      = data.aws_vpc.selected.id

  dynamic "ingress" {
    for_each = module.security_rules.ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = module.security_rules.egress_rules
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }

  tags = merge(
    var.common_tags,
    {
      Name = "myweb-${terraform.workspace}"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}