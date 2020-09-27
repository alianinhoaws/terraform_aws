output "bastion_ip" {
  value = aws_eip.bastion_static_ip.public_ip
}

output "ssh_key" {
  value = aws_key_pair.ssh.id
}