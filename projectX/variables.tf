variable "region" {
//  description = "Please set AWS region to deploy"
//  type = string
  default = "eu-west-1"
}

variable "instance_type" {
  default = "t2.micro"
  description = "Instance type"
  type = string
}
variable "allow_ports" {
  default = ["80", "443", "8080"]
  description = "List of ports"
  type = list
}
variable "cidr_blocks" {
  default = ["0.0.0.0/0"]
  description = "CIDR"
  type = list
}
variable "tags" {
  description = "Tags for all resources"
  type = map
  default = {
    Name = "AmazonServer"
    CostCenter = "Andrii"
    Project = "terraform"
    Environment = "DEV"
  }
}