#=================OUTPUT================
# use terraform output to print OLD output before terraform apply 
# terraform show - print all data that u can use to output (id ami etc...)

output "private-key-pem" {
  value     = tls_private_key.generation-key.private_key_pem
  sensitive = true
}

output "ec2-public-ip" {
  description = "The public IP of the EC2 instance"
  value       = aws_instance.web-server-ec2.public_ip
}

output "elastic-IP" {
  description = "The Elastic IP of the EC2 instance"
  value       = aws_eip.elastic_ip.public_ip
}

output "security-group-ingress" {
  description = "Security Group Ingress of the EC2 instance"
  value = aws_security_group.web-server-sg.ingress
}

output "security-group-id" {
  description = "Security Group ID of the EC2 instance"
  value = aws_security_group.web-server-sg.id
}

output "secret-manager" {
  description = "Secret manager ARN of the key"
  value = aws_secretsmanager_secret.ec2_private_key_secret.arn
}