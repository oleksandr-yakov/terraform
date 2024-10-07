provider "aws" {
  region = "eu-central-1"
}

# Security Group for EC2
resource "aws_security_group" "web-server-sg" {
  name   = "web-server-sg"

  dynamic "ingress" {
    for_each = ["80", "443", "8080", "1541", "9092", "9093"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ec2_dynamic" {
  for_each                    = toset(["t3.micro", "t2.micro", "t2.small", "t3.2xlarge"]) # |
  ami                         = "ami-00f07845aed8c0ee7"                                   # |  
  instance_type               = each.key                             # <------------------- v 
  vpc_security_group_ids      = [aws_security_group.web-server-sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "web-server-${each.key}"
  }
}

