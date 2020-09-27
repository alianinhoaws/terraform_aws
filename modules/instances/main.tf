//resource "aws_instance" "my_amazon" {
//  #count        = 1
//  ami           = data.aws_ami.latest_amazon_linux.id
//  instance_type = "t3.micro"
//  vpc_security_group_ids = [aws_security_group.web.id]
//  user_data = templatefile("user_data.sh.tpl", {
//    name    = "Andrii"
//    surname = "Maz"
//    names   = ["An", "Alex","others", "adada"]
//  })
//
//  tags = {
//    Name    = "AmazonServer"
//    owner   = "Andrii"
//    project = "terraform"
//  }
//  lifecycle {
//    create_before_destroy = true
//  }
//    depends_on = [aws_instance.my_amazon_db]
//}

resource "aws_instance" "test" {
  #count         = 1
  ami           = var.amazon_linux
  instance_type = var.instance_type
  vpc_security_group_ids = [var.aws_security_group]
  subnet_id = var.subnets[0]
  tags = {
    Name    = "AmazonServerTest"
    owner   = "Andrii"
    project = "terraform"
  }
  lifecycle {
    create_before_destroy = true
  }
  key_name = var.ssh-key
}


//data "aws_instances" "aws_instance_ip" {
//  aws_instance = aws_instance.test.private_ip
//}