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

resource "aws_instance" "sandbox_web" {
  count = 2 # create 2 instances

  ami           = "" # using https://aws.amazon.com/marketplace/pp/prodview-lzep7hqg45g7k for sample nginx plugin
  instance_type = "t2.nano"

  vpc_security_group_ids = [
    aws_security_group.sandbox_web.id
  ]
}

resource "aws_eip" "sandbox_web" {
  # instance = aws_instance.sandbox_web.id
}

resource "aws_eip_association" "sandbox_web" {
  instance_id = aws_instance.sandbox_web[0].id
  allocation_id = aws_eip.sandbox_web.id
}

resource "aws_default_subnet" "default_az1" {
  availability_zone = "ap-southeast-1a"
}

resource "aws_default_subnet" "default_az2" {
  availability_zone = "ap-southeast-1b"
}

resource "aws_elb" "sandbox_web" {
  name            = "sandbox-web"
  instances       = aws_instance.sandbox_web.*.id
  subnets         = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]
  security_groups = [aws_security_group.sandbox_web.id]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
}

resource "aws_default_vpc" "default_network" {}