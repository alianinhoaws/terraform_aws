variable "region" {
  description = "AWS region to deploy"
  type = string
  default = "eu-west-1"
}

variable "instance_type" {
  default = "t2.micro"
  description = "Instance type"
  type = string
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

variable "env" {
  default = "dev"
}

variable "ec2_size" {
  description = "Environment to rise"
  type = map
  default = {
    "prod" : "t2.small"
    "dev" : "t2.micro"
  }
}

variable "allow_ports" {
  type = map
  default = {
    "prod" = ["80","443"]
    "dev"  = ["80", "443", "8080"]
  }
}