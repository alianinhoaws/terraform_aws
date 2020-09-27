variable "allow_ports" {
  description = "List of ports"
  type = map
}
variable "cidr_blocks" {
  description = "CIDR"
  type = list
}
variable "tags" {
  description = "Tags for all resources"
}
variable "vpc" {
  description = "main vpc"
}

variable "subnets_cidrs" {
  description = "subnets CIDR"
}

variable "public_subnets_cidrs" {
  description = "public subnets CIDR"
}
variable "env" {
  description = "environment to rise"
}