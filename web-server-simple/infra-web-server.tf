provider "aws" {
  region = "eu-central-1"
}

resource "aws_security_group" "web-server-sg" {
  name        = "basic-sg"
  description = "Allow inbound HTTP traffic from the world"

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow-ssh" {
  security_group_id = aws_security_group.web-server-sg.id
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "allow-http" {
  security_group_id = aws_security_group.web-server-sg.id
  ip_protocol       = "tcp"
  from_port         = 80
  cidr_ipv4         = "0.0.0.0/0"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allow-egress" {
  security_group_id = aws_security_group.web-server-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports

}

resource "tls_private_key" "generation-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "main-key-id" {
  key_name   = "main-key"
  public_key = tls_private_key.generation-key.public_key_openssh
}

output "private_key_pem" {
  value     = tls_private_key.generation-key.private_key_pem
  sensitive = true
}

output "ec2_public_ip" {
  description = "The public IP of the EC2 instance"
  value       = aws_instance.web-server-ec2.public_ip
}

# resource "aws_eip" "elastic-for-web" {
#   instance = aws_instance.web-server-ec2.id
#   domain   = "vpc"

# }

resource "aws_eip" "elastic_ip" {
  domain = "vpc"
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.web-server-ec2.id
  allocation_id = aws_eip.elastic_ip.id
}

output "elastic_ip" {
  description = "The Elastic IP of the EC2 instance"
  value       = aws_eip.elastic_ip.public_ip
}

resource "aws_instance" "web-server-ec2" {
  ami                         = "ami-00f07845aed8c0ee7"
  instance_type               = "t3.micro"
  key_name                    = aws_key_pair.main-key-id.key_name
  vpc_security_group_ids      = [aws_security_group.web-server-sg.id]
  user_data_replace_on_change = true # This need to added!!!!  
  user_data                   = file("../example-web-httpd.sh")
  #   user_data                   = <<EOF
  # #!/bin/bash
  # yum -y update
  # yum -y install httpd
  # myip=$(curl http://checkip.amazonaws.com)
  # echo "<h2>WebServer with IP: $myip</h2><br>Build by Terraform!"  >  /var/www/html/index.html
  # sudo service httpd start
  # chkconfig httpd on
  # EOF
  tags = {
    Name = "web-server-ec2"
  }
}


resource "aws_secretsmanager_secret" "ec2_private_key_secret" {
  name = "ec2-key-web-serv"
}

resource "aws_secretsmanager_secret_version" "ec2_private_key_version" {
  secret_id     = aws_secretsmanager_secret.ec2_private_key_secret.id
  secret_string = tls_private_key.generation-key.private_key_pem
}

