provider "aws" {
  region = "eu-central-1"
}

resource "aws_security_group" "web-server-sg" {
  name        = "basic-sg"
  description = "Allow inbound HTTP traffic from the world"
  dynamic "ingress" {
    for_each = ["80", "22"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  tags = {
    Name = "Terraform",
    Ovner = "Alex Yakov"
  }
}


resource "aws_vpc_security_group_egress_rule" "allow-egress" {
  security_group_id = aws_security_group.web-server-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports

}

#======================TLS and KEY pair SETUP =================
resource "tls_private_key" "generation-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "main-key-id" {
  key_name   = "main-key"
  public_key = tls_private_key.generation-key.public_key_openssh
}

# resource "aws_eip" "elastic-for-web" {
#   instance = aws_instance.web-server-ec2.id
#   domain   = "vpc"

# }

#====================Elastic IP =================
resource "aws_eip" "elastic_ip" {
  domain = "vpc"
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.web-server-ec2.id
  allocation_id = aws_eip.elastic_ip.id
}

resource "aws_instance" "web-server-ec2" {
  ami                         = "ami-00f07845aed8c0ee7"
  instance_type               = "t3.micro"
  key_name                    = aws_key_pair.main-key-id.key_name
  vpc_security_group_ids      = [aws_security_group.web-server-sg.id]
  user_data_replace_on_change = true # This need to added!!!!  
  user_data = templatefile("../template-web-server.tpl", {
    owner_name    = "Alex Yakov",
    server_name   = "Web Server",
    elastic_ip    = aws_eip.elastic_ip.public_ip,
    owner_email   = "alex@example.com"
    companys_name = ["Samsung", " Apple", " Google", " Facebook", " Twitter", "XXXXXXXXXXXXXXX"]
  })
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

  lifecycle {
    
              /*prevent_destroy забороняє видаляти ресурс, навіть якщо він є у плані на видалення.
              Це важливо для критичних ресурсів, які не повинні випадково бути знищені.*/
    # prevent_destroy = true

              /*ignore_changes ігнорує зміни у вказаних полях під час наступних запусків.
              Terraform не буде намагатися перезапустити або змінити інстанс через ці зміни.*/
    # ignore_changes = [ "ami", "instance_type", "user_data" ]

              /*create_before_destroy змушує Terraform спочатку створити новий ресурс, а тільки потім видалити старий.
              Це корисно для ресурсів, які не повинні зникати під час оновлення (наприклад, важливі сервіси чи інстанси).
              Terraform створить новий ресурс, перенесе до нього всі залежності, і лише після цього знищить старий ресурс.*/
    create_before_destroy = true
    
  }
}


#====================Secret Manager =================
resource "aws_secretsmanager_secret" "ec2_private_key_secret" {
  name = "ec2-key-web-serve1"
}

resource "aws_secretsmanager_secret_version" "ec2_private_key_version" {
  secret_id     = aws_secretsmanager_secret.ec2_private_key_secret.id
  secret_string = tls_private_key.generation-key.private_key_pem
}


