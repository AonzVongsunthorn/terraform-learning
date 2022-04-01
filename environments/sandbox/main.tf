provider "aws" {
  profile = "default"
  region = "ap-southeast-1"
}

resource "aws_s3_bucket" "sandbox_terraform_demo" {
  bucket  = "terraform-demo-20220401"
}

resource "aws_s3_bucket_acl" "sandbox_terraform_demo_acl" {
  bucket = aws_s3_bucket.sandbox_terraform_demo.id
  acl    = "private"
}

resource "aws_security_group" "sandbox_web" {
  name          = "sandbox_web"
  description   = "Allow standard http and https ports inbound and everything outbound"

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Terraform" : "true"
  }
}
