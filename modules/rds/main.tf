resource "aws_ssm_parameter" "rds_password" {
  name = var.pass_location
  type = var.pass_type
  value = var.pass
}

data "aws_ssm_parameter" "rds_password" {
  name = var.pass_location
  depends_on = [aws_ssm_parameter.rds_password]
}

resource "aws_db_instance" "rds" {
  identifier             = var.identifier
  allocated_storage      = var.storage_size
  storage_type           = var.storage_type
  engine                 = var.mysql_engine
  engine_version         = var.mysql_engine_version
  instance_class         = var.instance_class
  name                   = var.db_name
  username               = var.user_name
  password               = data.aws_ssm_parameter.rds_password.value
  parameter_group_name   = var.mysql_type_group
  vpc_security_group_ids = [var.security_rds]
  skip_final_snapshot    = true
  apply_immediately      = true
  db_subnet_group_name   = aws_db_subnet_group.database.id
  depends_on             = [aws_db_subnet_group.database]
}

resource "aws_db_subnet_group" "database" {
  name                   = "database-subnet-group"
  subnet_ids             = var.aws_subnet
}