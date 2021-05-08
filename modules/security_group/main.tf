resource "aws_security_group" "web" {
  name        = "web_server"
  description = "Allow web traffic"
  vpc_id = var.vpc

  dynamic "ingress" {
    for_each = lookup(var.allow_ports, var.env)
    content {
      from_port = ingress.value
      to_port = ingress.value
      protocol = "tcp"
      cidr_blocks = var.cidr_blocks
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
    tags = merge(var.tags, {Name = "allow_web"})

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_security_group" "bastion" {
  name        = "bastion_server"
  description = "Allow only ssh traffic"
  vpc_id = var.vpc

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
    tags = merge(var.tags, {Name = "allow_ssh"})

  lifecycle {
    create_before_destroy = true
  }
}



resource "aws_security_group" "rds" {
  name        = "RDS"
  description = "Allow all from public subnets"
  vpc_id = var.vpc

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = var.public_subnets_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
    tags = merge(var.tags, {Name = "RDS"})

  lifecycle {
    create_before_destroy = true
  }
}