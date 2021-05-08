variable "subnets" {
  description = "subnets for instances to locate"
}

variable "security_group" {
  description = "security group open ports in instances"
}

variable "ami_image" {
  description = "ami image to use"
}

variable "instance_type" {
  description = "machine type of the instance"
}

variable "tags" {
  description = "env tags to apply"
}

variable "vpc" {
  description = "main vpc to locate target group"
}

variable "name_prefix" {
  description = "name prefix of the instances"
}
