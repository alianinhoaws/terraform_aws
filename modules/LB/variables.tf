variable "security_group_lb" {
  description = "ports for LB"
}

variable "public_subnets" {
  description = "subnets for LB to locate"
}

variable "aws_s3_bucket" {
  description = "bucket for save logs"
}
variable "name" {
  description = "name of the balancer"
}
variable "target_group_lambda" {
  description = "target groups Lambda to listen"
}
variable "target_group_instances" {
  description = "target groups Instances to listen"
}