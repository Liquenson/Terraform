# Load Balancer
resource "aws_lb" "myweb" {
  provider           = aws.primary
  name               = "myweb-lb-${terraform.workspace}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.myweb.id]
  subnets            = data.aws_vpc.selected.subnet_ids

  tags = var.common_tags
}

# Target Group
resource "aws_lb_target_group" "myweb" {
  provider    = aws.primary
  name        = "myweb-tg-${terraform.workspace}"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.selected.id
  target_type = "instance"

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 10
  }

  tags = var.common_tags
}

# Listener
resource "aws_lb_listener" "myweb" {
  provider          = aws.primary
  load_balancer_arn = aws_lb.myweb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.myweb.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.myweb.arn
  }
}

# Certificado SSL
resource "aws_acm_certificate" "myweb" {
  provider          = aws.primary
  domain_name       = "example.com"
  validation_method = "DNS"

  tags = var.common_tags

  lifecycle {
    create_before_destroy = true
  }
}