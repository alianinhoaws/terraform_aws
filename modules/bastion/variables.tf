variable "amazon_linux" {
  description = "latest ami amazon 2 linux"
}

variable "security_group_bastion" {
  description = "ssh only security group"
}

variable "instance_type" {
  description = "instance type"
}

variable "subnets" {
  description = "public subnets for bastion to locate"
}