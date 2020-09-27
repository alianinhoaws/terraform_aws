variable "amazon_linux" {
  description = "latest ami of amazon2 linux"
}

variable "subnets" {
  description = "list of private subnets"
}

variable "aws_security_group" {
  description = "allow ssh"
}

variable "instance_type" {
  description = "machine type of the instance"
}

variable "ssh-key" {
  description = "key for ssh connection"
}
