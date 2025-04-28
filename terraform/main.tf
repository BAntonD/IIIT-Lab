terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
}

resource "aws_key_pair" "this" {
  key_name   = "keysToIITLab5"  # Це ім'я, яке буде присвоєно твоєму ключу в AWS.
  public_key = file("keysToIITLab5.pem.pub")  # Вказуємо шлях до публічного ключа.
}


resource "aws_security_group" "web_sg" {
  name = "allow_http_and_ssh"

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH"
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

resource "aws_instance" "web_server" {
  ami           = "ami-0c1ac8a41498c1a9c" # або актуальний для твого регіону
  instance_type = "t2.micro"

  key_name               = aws_key_pair.this.key_name
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y docker.io
              systemctl start docker
              systemctl enable docker
              docker login -u ${var.docker_username} -p ${var.docker_password}
              docker run -d -p 80:80 ${var.docker_username}/your_image_name:latest
              docker run -d --restart always -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower
              EOF

  tags = {
    Name = "TerraformWebServer"
  }
}
