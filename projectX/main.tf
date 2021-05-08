provider "aws" {
  region   = var.region
}

data "aws_availability_zones" "available"{}
data "aws_region" "current"{}

locals {
  az_list = join("", data.aws_availability_zones.available.names)
  location = "${local.az_list} in ${data.aws_region.current.name}"
  instance_type = lookup(var.ec2_size, var.env)
  public_subnets = ["10.100.1.0/24", "10.100.2.0/24"]
  #instance_type = (var.env == "prod" ? "t3.micro" : "t2.micro") #can be refactored to use as tf_vars
}

terraform {
  backend "s3" {
    bucket = "terraform-alianinho"
    key    = "dev/main/terraform.tfstate"
    region = "eu-west-1"
  }
}

module "vpc" {
  source = "../modules/network"
  env                  = "prod"
  vpc_cidr             = "10.100.0.0/16"
  public_subnet_cidrs  = local.public_subnets
  private_subnet_cidrs = ["10.100.11.0/24", "10.100.22.0/24"]
}

resource "null_resource" "command1" {
  provisioner "local-exec" {
    command = "echo Terraform start: $(data) executor $(name) >> log.txt"
    environment = {
      name = "Andrii"
    }
  }
}

resource "null_resource" "command2" {
  provisioner "local-exec" {
    command = "echo Terraform end: $(data) executor $(name) >> log.txt"
    environment = {
      name = "Andrii"
    }
  }
  depends_on = [module.bastion,module.security_group,module.test-instances]
}

module "security_group" {
  source = "../modules/security_group"
  tags = var.tags
  allow_ports = var.allow_ports
  cidr_blocks = var.cidr_blocks
  vpc = module.vpc.vpc_id
  subnets_cidrs = module.vpc.private_subnet_cidr
  depends_on = [module.vpc]
  env = var.env
  public_subnets_cidrs = local.public_subnets
}

module "database" {
  source = "../modules/rds"
  depends_on = [module.vpc]
  aws_subnet = module.vpc.public_subnet_ids
  pass = "adadsdqwe"
  security_rds = module.security_group.security_group_rds
  identifier = "mysql-prod"
  storage_size = 20
  storage_type = "gp2"
  mysql_engine_version = "5.7"
  mysql_engine = "mysql"
  mysql_type_group = "default.mysql5.7"
  user_name = "db_user"
  db_name = "terraform_database"
  instance_class = "db.t2.micro"
  pass_type = "SecureString"
  pass_location = "/prod/mysql"
}

module "bastion" {
  source = "../modules/bastion"
  amazon_linux = data.aws_ami.latest_amazon_linux.id
  security_group_bastion = module.security_group.security_group_bastion
  depends_on = [module.vpc]
  instance_type = local.instance_type
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

module "test-instances" {
  source = "../modules/instances"
  amazon_linux = data.aws_ami.latest_amazon_linux.id
  aws_security_group = module.security_group.security_group_bastion
  depends_on = [module.vpc]
  instance_type = local.instance_type
  subnets = module.vpc.private_subnet_ids
  ssh-key = module.bastion.ssh_key
  instnace_count = 1
}

module "lambda" {
  source = "../modules/lambda"
  vpc = module.vpc.vpc_id
  file_path = "../modules/lambda/exports.js.zip"

}

module "lb" {
  source = "../modules/LB"
  aws_s3_bucket = module.bucket.bucket_name
  name = "app-balancer"
  public_subnets = module.vpc.public_subnet_ids
  security_group_lb = module.security_group.security_group_web
  target_group_lambda = module.lambda.lambda_name_arn
  target_group_instances = module.web.instances_tg_arn
}

module "bucket" {
  source = "../modules/bucket"
}

module "web" {
  source = "../modules/web"
  instance_type = local.instance_type
  ami_image = data.aws_ami.latest_amazon_linux.id
  security_group = module.security_group.security_group_web
  subnets = module.vpc.public_subnet_ids
  tags = var.env
  vpc = module.vpc.vpc_id
  name_prefix = "Blue/Green"
}
