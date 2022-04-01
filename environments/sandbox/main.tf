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

resource "aws_default_subnet" "default_az1" {
  availability_zone = "ap-southeast-1a"
}

resource "aws_default_subnet" "default_az2" {
  availability_zone = "ap-southeast-1b"
}

resource "aws_elb" "sandbox_web" {
  name            = "sandbox-web"
  # instances       = aws_instance.sandbox_web.*.id
  subnets         = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]
  security_groups = [aws_security_group.sandbox_web.id]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
}

resource "aws_launch_template" "sandbox_web" {
  name_prefix = "sandbox-web"
  image_id = ""
  instance_type = "t2.micro"
}

resource "aws_autoscaling_group" "sandbox_web" {
  # availability_zones = ['ap-southeast-1a', 'ap-southeast-1b']
  vpc_zone_identifier = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]
  desired_capacity    = 1
  max_size            = 1
  min_size            = 1

  launch_template {
    id      = aws_launch_template.sandbox_web.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_attachment" "sandbox_web" {
  autoscaling_group_name = aws_autoscaling_group.sandbox_web.id
  elb = aws_elb.sandbox_web.id
}

resource "aws_default_vpc" "default_network" {}