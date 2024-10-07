provider "aws" {
  region = "eu-central-1"
}

resource "aws_instance" "ubuntu" {
  count         = 1
  ami           = "ami-0e04bcbe83a83792e"
  instance_type = "t3.micro"
  tags = {
    Name    = "basic  ubuntu"
    Owner   = "Alex"
    Project = "Terraform basic project"
  }
}

resource "aws_instance" "amz" {
  ami           = "ami-00f07845aed8c0ee7"
  instance_type = "t3.micro"
  tags = {
    Name    = "basic  amz"
    Owner   = "Alex"
    Project = "Terraform basic project"
  }
}