provider "aws" {
  region   = var.region
}

//locals {
//  az_list  = join(",", data.aws_availability_zones.available.names)
//  region   = var.region
//  location = "In $local.az_list"
//  country  = "Israel"
//  city     = "Haifa"
//}

module "vpc" {
  source = "../modules/network"
  env                  = "prod"
  vpc_cidr             = "10.100.0.0/16"
  public_subnet_cidrs  = ["10.100.1.0/24", "10.100.2.0/24"]
  private_subnet_cidrs = ["10.100.11.0/24", "10.100.22.0/24"]

}

resource "null_resource" "comand1" {
  provisioner "local-exec" {
    command = "echo Terraform start: $(data) >> log.txt"
  }
}

module "security_group" {
  source = "../modules/security_group"
  tags = var.tags
  allow_ports = var.allow_ports
  cidr_blocks = var.cidr_blocks
  vpc = module.vpc.vpc_id
  subnets_cidrs = module.vpc.private_subnet_cidr
  depends_on = [module.vpc]
}

module "database" {
  source = "../modules/rds"
  depends_on = [module.vpc]
  #aws_subnet = element(module.vpc.private_subnet_ids[*], count.index)
  #aws_subnet = [module.vpc.private_subnet_ids[0], module.vpc.private_subnet_ids[1]]
  aws_subnet = module.vpc.private_subnet_ids
  pass = "adadsdqwe"
  security_rds = module.security_group.security_group_rds
}

module "bastion" {
  source = "../modules/bastion"
  #"bucket_name" = "my_famous_bucket_name"
  #"region" = "eu-west-1"
//  vpc_id = "my_vpc_id"
//  is_lb_private = "true|false"
//  bastion_host_key_pair = "my_key_pair"
//  hosted_zone_id = "my.hosted.zone.name."
//  bastion_record_name = "bastion.my.hosted.zone.name."
//  bastion_iam_policy_name = "myBastionHostPolicy"
  amazon_linux = data.aws_ami.latest_amazon_linux.id
  security_group_bastion = module.security_group.security_group_bastion
  depends_on = [module.vpc]
  instance_type = "t2.micro"

  subnets = module.vpc.public_subnet_ids
}


data "aws_ami" "latest_amazon_linux"{
  owners      = ["amazon"]
  most_recent = true
  filter {
    name      = "name"
    values    = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

//resource "random_string" "rds_password" {
//  length = 12
//  special = True
//  override_special = "!#$&"
//  keepers = {
//    keeper1 = var.region
//  }
//}
//

module "test-instances" {
  source = "../modules/instances"
  amazon_linux = data.aws_ami.latest_amazon_linux.id
  aws_security_group = module.security_group.security_group_bastion
  depends_on = [module.vpc]
  instance_type = "t2.micro"
  subnets = module.vpc.private_subnet_ids
}
