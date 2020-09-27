

output "security_group_bastion" {
  value = aws_security_group.bastion.id
}

output "security_group_web" {
  value = aws_security_group.web.id
}


output "security_group_rds" {
  value = aws_security_group.rds.id
}
