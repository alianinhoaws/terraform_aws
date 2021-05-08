
resource "aws_instance" "test" {
  #count         = var.instnace_count
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

