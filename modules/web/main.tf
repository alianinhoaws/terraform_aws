
resource "aws_launch_configuration" "web"{
  name_prefix     = var.name_prefix
  image_id        = var.ami_image
  instance_type   = var.instance_type
  security_groups = [var.security_group]
  user_data       = templatefile("../modules/web/user_data.sh.tpl", {
    name          = "Andrii"
    surname       = "Maz"
    names         = ["Step", "The academy", "The best academy in the whole world", "thanks terraform"]
  })
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "web" {
  name = "Web-${aws_launch_configuration.web.name}"
  max_size = 5
  min_size = 2
  min_elb_capacity = 1
  vpc_zone_identifier = var.subnets
  health_check_grace_period = 60
  health_check_type = "EC2"
  desired_capacity = 2
  default_cooldown = 60
  target_group_arns = [aws_alb_target_group.instances.arn]
  launch_configuration = aws_launch_configuration.web.name

  dynamic "tag" {
    for_each = {
      Name    = "WebServer ${var.name_prefix}"
      Owner   = "Andrii"
      TAGKEY  = "TAGVALUE"
    }
    content {
    key = tag.key
    value = tag.value
    propagate_at_launch = true
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_alb_target_group" "instances" {
  name     = "instances-terraform"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc
}


resource "aws_autoscaling_attachment" "instances" {
  autoscaling_group_name = aws_autoscaling_group.web.id
  alb_target_group_arn   = aws_alb_target_group.instances.arn
  depends_on       = [aws_autoscaling_group.web]
}

resource "aws_autoscaling_policy" "example-cpu-policy" {
  name = "example-cpu-policy"
  autoscaling_group_name = aws_autoscaling_group.web.name
  adjustment_type = "ChangeInCapacity"
  scaling_adjustment = "1"
  cooldown = "30"
  policy_type = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "example-cpu-alarm" {
  alarm_name = "example-cpu-alarm"
  alarm_description = "example-cpu-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "1"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "60"
  statistic = "Average"
  threshold = "30"
  dimensions = {
  "AutoScalingGroupName" = aws_autoscaling_group.web.name
  }
  actions_enabled = true
  alarm_actions = [aws_autoscaling_policy.example-cpu-policy.arn]

}

resource "aws_autoscaling_policy" "example-cpu-policy-scaledown" {
  name = "example-cpu-policy-scaledown"
  autoscaling_group_name = aws_autoscaling_group.web.name
  adjustment_type = "ChangeInCapacity"
  scaling_adjustment = "-1"
  cooldown = "30"
  policy_type = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "example-cpu-alarm-scaledown" {
  alarm_name = "example-cpu-alarm-scaledown"
  alarm_description = "example-cpu-alarm-scaledown"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods = "1"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "60"
  statistic = "Average"
  threshold = "5"
  dimensions = {
  "AutoScalingGroupName" = aws_autoscaling_group.web.name
  }
  actions_enabled = true
  alarm_actions = [aws_autoscaling_policy.example-cpu-policy-scaledown.arn]
}
