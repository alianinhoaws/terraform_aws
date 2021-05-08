locals {type = "forward"}

resource "aws_lb" "test" {
  name               = var.name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group_lb]
  subnets            = var.public_subnets

  enable_deletion_protection = false


  tags = {
    Environment = var.env
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.test.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy_type
  certificate_arn   = var.sertificate

  default_action {
    type             = local.type
    target_group_arn = var.target_group_lambda
  }
}

resource "aws_lb_listener" "front_end2" {
  load_balancer_arn = aws_lb.test.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = local.type
    target_group_arn = var.target_group_instances
  }
}

resource "aws_route53_zone" "main" {
  name = var.dns_name
}


resource "aws_route53_record" "a" {

  zone_id = aws_route53_zone.main.zone_id
  name    = var.dns_name
  type    = "A"

  alias {
    name                   = aws_lb.test.dns_name
    zone_id                = aws_lb.test.zone_id
    evaluate_target_health = true
  }
}
