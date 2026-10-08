terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "eu-west-2"
}

resource "aws_instance" "example" {
  ami           = "ami-0e5df6fd7455a69b3"
  instance_type = "t3.micro"

  key_name = aws_key_pair.ec2_key.key_name

  vpc_security_group_ids = [
    aws_security_group.allow_ssh.id,
    aws_security_group.allow_http.id
  ]

  user_data = <<-EOF
    #!/bin/bash
    dnf update -y
    dnf install nginx -y
    systemctl enable nginx
    systemctl start nginx
  EOF
}

resource "aws_key_pair" "ec2_key" {
  key_name   = "new-ec2-key"
  public_key = file("new-ec2-key.pub")
}

resource "aws_security_group" "allow_ssh" {
  name = "allow-ssh"

  ingress {
    description = "SSH"
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


resource "aws_security_group" "allow_http" {
  name = "allow-http"

  ingress {
    description = "http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_route53_record" "root" {
    zone_id = data.aws_route53_zone.main.zone_id
    name    = data.aws_route53_zone.main.name
    type    = "A"
    ttl     = 300

    records = [aws_instance.example.public_ip]

}

data "aws_route53_zone" "main" {
  name = "adilselimovic.com"
  private_zone = false
}