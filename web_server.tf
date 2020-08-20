provider "aws" {
  region     = "eu-north-1"
}

resource "aws_eip" "amaz_static_ip" {
  vpc                       = true
  instance = aws_instance.my_amazon.id
}

resource "aws_instance" "my_amazon" {
  #count         = 1
  ami           = "ami-039609244d2810a6b"
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.web.id]
  user_data = templatefile("user_data.sh.tpl", {
    name    = "Andrii"
    surname = "Maz"
    names   = ["An", "Alex","others", "adada"]
  })

  tags = {
    Name    = "AmazonServer"
    owner   = "Andrii"
    project = "terraform"
  }
  lifecycle {
    create_before_destroy = true
  }
    depends_on = [aws_instance.my_amazon_db]
}

resource "aws_instance" "my_amazon_db" {
  #count         = 1
  ami           = "ami-039609244d2810a6b"
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.web.id]

  tags = {
    Name    = "AmazonServerDB"
    owner   = "Andrii"
    project = "terraform"
  }
  lifecycle {
    create_before_destroy = true
  }

}


resource "aws_security_group" "web" {
  name        = "web_server"
  description = "Allow web traffic"

  dynamic "ingress" {
    for_each = ["80", "443", "8080"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["77.123.0.0/16"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_web"
  }
}

