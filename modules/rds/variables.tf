variable "aws_subnet" {
  description = "DB subnets"
}

variable "pass" {
  description = "Generated password for the DB"
}

variable "pass_location" {
  description = "location of the pass"
}

variable "pass_type" {
  description = "type of the pass"
}

variable "security_rds" {
  description = "Firewall rule"
}

variable "instance_class" {
  description = "type of the instance"
}

variable "db_name" {
  description = "name of the DB to init"
}

variable "user_name" {
  description = "name of the database user"
}

variable "mysql_type_group" {
  description = "type of the RDS"
}

variable "mysql_engine" {
  description = "type of RDS"
}

variable "mysql_engine_version" {
  description = "version of mysql to use"
}

variable "storage_type" {
  description = "type of the storage"
}

variable "storage_size" {
  description = "amount of storage"
}

variable "identifier" {
  description = "name of the instance"
}