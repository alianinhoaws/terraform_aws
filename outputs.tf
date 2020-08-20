output "web_public_ip" {
  value = aws_eip.amaz_static_ip.public_ip
  description = "Bounded external ip address"
}

output "db_ip" {
  value = aws_instance.my_amazon_db.private_ip
  description = "DB ip address"
}