provider "aws" {
  profile = "default"
  region = "ap-southeast-1"
}

resource "aws_s3_bucket" "sandbox_terraform_demo" {
  bucket  = "terraform-demo"
}

resource "aws_s3_bucket_acl" "sandbox_terraform_demo_acl" {
  bucket = aws_s3_bucket.sandbox_terraform_demo.id
  acl    = "private"
}

