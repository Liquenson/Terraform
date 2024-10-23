# Grupo de Auto Scaling
resource "aws_autoscaling_group" "myweb" {
  provider            = aws.primary
  name                = "myweb-asg-${terraform.workspace}"
  vpc_zone_identifier = data.aws_vpc.selected.subnet_ids
  target_group_arns   = [aws_lb_target_group.myweb.arn]
  health_check_type   = "ELB"
  min_size            = 2
  max_size            = 10
  desired_capacity    = 2

  launch_template {
    id      = aws_launch_template.myweb.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "myweb-instance-${terraform.workspace}"
    propagate_at_launch = true
  }
}

# Plantilla de lanzamiento
resource "aws_launch_template" "myweb" {
  provider      = aws.primary
  name_prefix   = "myweb-lt-${terraform.workspace}"
  image_id      = data.aws_ami.amazon_linux_2.id
  instance_type = "t3.micro"

  vpc_security_group_ids = [aws_security_group.myweb.id]

  user_data = base64encode(<<-EOF
              #!/bin/bash
              echo "Hello from Terraform!" > index.html
              nohup python -m SimpleHTTPServer 80 &
              EOF
  )

  tags = var.common_tags
}

# Auto Scaling Policy
resource "aws_autoscaling_policy" "scale_up" {
  provider               = aws.primary
  name                   = "scale-up-${terraform.workspace}"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.myweb.name
}