resource "aws_lb" "test" {
  name               = var.name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group_lb]
  subnets            = var.public_subnets

  enable_deletion_protection = false

//  access_logs {
//    bucket  = var.aws_s3_bucket
//    prefix  = var.name
//    enabled = true
//  }


  tags = {
    Environment = "production"
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.test.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:acm:eu-west-1:180243171467:certificate/7af7ce5f-5233-4813-90a3-1c38689ab0d7"

  default_action {
    type             = "forward"
    target_group_arn = var.target_group_lambda
  }
}

resource "aws_lb_listener" "front_end2" {
  load_balancer_arn = aws_lb.test.arn
  port              = "80"
  protocol          = "HTTP"
  #ssl_policy        = "ELBSecurityPolicy-2016-08"
  #certificate_arn   = "arn:aws:acm:eu-west-1:180243171467:certificate/7af7ce5f-5233-4813-90a3-1c38689ab0d7"

  default_action {
    type             = "forward"
    target_group_arn = var.target_group_instances
  }
}

resource "aws_route53_zone" "main" {
  name = "alianinho.ml"
}

//resource "aws_route53_zone" "dev" {
//  name = "api.alianinho.ml"
//
//  tags = {
//    Environment = "dev"
//  }
//}

resource "aws_route53_record" "a" {

  zone_id = aws_route53_zone.main.zone_id
  name    = "alianinho.ml"
  type    = "A"
  #ttl     = "30"
  #records = aws_route53_zone.main.name_servers

  alias {
    name                   = aws_lb.test.dns_name
    zone_id                = aws_lb.test.zone_id
    evaluate_target_health = true
  }

}
