//output "web_public_ip" {
//  value = aws_eip.amaz_static_ip.public_ip
//  description = "Bounded external ip address"
//}
//
//output "db_ip" {
//  value = aws_instance.my_amazon_db.private_ip
//  description = "DB ip address"
//}
//
//
//output "prod_vpc_id" {
//  value = data.aws_vpc.prod_vpc.id
//}
//output "prod_vpc_cidr" {
//  value = data.aws_vpc.prod_vpc.cidr_block
//}

//output "data_aws_availability_zones" {
//  value = data.aws_availability_zones.working.names
//}
//output "data_aws_subnet_name" {
//  value = aws_subnet.prod_sub1.id
//}
//output "data_aws_subnet_cidr" {
//  value = aws_subnet.prod_sub1.cidr_block
//}

//output "password_rds" {//output "data_aws_ami_amazon_linux_latest" {
////  value = data.aws_ami.latest_amazon_linux.id
////}
////output "web_loadbalancer_url" {
////  value = aws_elb.web.dns_name
////}
////
//////output "rds_endpoint" {
//////  value = aws_db_instance.rds.endpoint
//////}
//////
//////output "rds_port" {
//////  value = aws_db_instance.rds.port
//////}
////
////output "bastion_ip" {
////  value = aws_launch_configuration.bastion.associate_public_ip_address
////}
//  value = aws_ssm_parameter.rds_password.value
//}


output "dev_public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "dev_private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "bastion_ip" {
  value = module.bastion.bastion_ip
}

output "test_ip" {
  value = module.test-instances.aws_instance_ip
}

output "rds_ip" {
  value = module.database.rds_ip
}
