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

variable "sertificate" {
  description = "SSL sertificate to use"
  default = "arn:aws:acm:eu-west-1:180243171467:certificate/7af7ce5f-5233-4813-90a3-1c38689ab0d7"
}

variable "ssl_policy_type" {
  description = "SSL policy"
  default = "ELBSecurityPolicy-2016-08"
}

variable "dns_name" {
  default = "alianinho.ml"
  description = "DNS name to attach on LB"
}

variable "env" {
  default = "prod"
  description = "env tag"
}