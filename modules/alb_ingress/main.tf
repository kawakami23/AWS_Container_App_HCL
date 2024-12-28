########################
# ALB
########################

# Define ingress ALB
resource "aws_lb" "ingress" {
  name               = "${var.common.env}-alb-ingress"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.network.public_subnet_for_ingress_ids
  security_groups    = [var.network.security_group_for_ingress_alb_id]
  tags = {
    Name = "${var.common.env}-alb-ingress"
  }
}

# Define the listner for ingress ALB
resource "aws_lb_listener" "ingress" {
  load_balancer_arn = aws_lb.ingress.arn
  protocol          = "HTTP"
  port              = "80"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ingress.arn
  }
}

# Define target group for ingress ALB
resource "aws_lb_target_group" "ingress" {
  name        = "${var.common.env}-tg-frontend"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.network.vpc_id
  health_check {
    protocol            = "HTTP"
    path                = "/healthcheck"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 15
    matcher             = 200
  }
}