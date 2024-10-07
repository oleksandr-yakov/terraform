
variable "instance_types" {
  description = "Список типів інстансів"
  type        = list(string)
  default     = ["t2.micro", "t3.micro", "t2.micro"]
}

variable "replica_counts" {
  description = "Кількість інстансів для кожного типу"
  type        = list(number)
  default     = [2, 1, 4] 
}

provider "aws" {
  region = "eu-central-1"
}

resource "aws_security_group" "web-server-sg" {
  name   = "web-server-sg"
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ec2_dynamic" {
  count = length(var.instance_types)

  for_each = {
    for index, instance_type in var.instance_types : index => {
      type  = instance_type
      count = element(var.replica_counts, index)
    }
  }

  ami                         = "ami-00f07845aed8c0ee7"
  instance_type               = each.value.type
  key_name                    = aws_key_pair.main-key-id.key_name
  vpc_security_group_ids      = [aws_security_group.web-server-sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "web-server-${each.value.type}-${count.index}"
  }
}

