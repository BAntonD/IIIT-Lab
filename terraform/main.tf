terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_eip" "existing" {
  public_ip = "13.49.90.115"
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.web_server.id
  allocation_id = "eipalloc-092ea8dbe4476fa68"
}





resource "aws_instance" "web_server" {
  ami           = "ami-04542995864e26699" # або актуальний для твого регіону
  instance_type = "t3.micro"

  key_name      = "keysToIITLab5"  # Використовуємо існуючий ключ
  vpc_security_group_ids = ["sg-0e26a6008f52977b3"]  # Використовуємо існуючу групу безпеки

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

