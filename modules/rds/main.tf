resource "aws_ssm_parameter" "rds_password" {
  name = "/prod/mysql"
  type = "SecureString"
  value = var.pass
}


//resource "random_string" "rds_password" {
//  length = 12
//  special = true
//  override_special = "!#$&"
//}

data "aws_ssm_parameter" "rds_password" {
  name = "/prod/mysql"
  depends_on = [aws_ssm_parameter.rds_password]
}

resource "aws_db_instance" "rds" {
  identifier             = "prod-mysql"
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t2.micro"
  name                   = "terraform_database"
  username               = "db_user"
  password               = data.aws_ssm_parameter.rds_password.value
  parameter_group_name   = "default.mysql5.7"
  vpc_security_group_ids = [var.security_rds]
  skip_final_snapshot    = true
  apply_immediately      = true
  db_subnet_group_name   = aws_db_subnet_group.database.id
  depends_on             = [aws_db_subnet_group.database]
}

resource "aws_db_subnet_group" "database" {
  name                   = "my-test-database-subnet-group"
  subnet_ids             = var.aws_subnet
}