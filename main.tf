terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.70"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "us-west-2"
}

resource "aws_eip" "ip" {
  vpc      = true
  instance = aws_instance.example.id
}

resource "tls_private_key" "this" {
  algorithm = "RSA"
}

module "key_pair" {
  source = "terraform-aws-modules/key-pair/aws"

  key_name   = "my-key"
  public_key = tls_private_key.this.public_key_pem
}


resource "aws_instance" "example" {
  ami           = "ami-01fee56b22f308154"
  instance_type = "t2.micro"
  key_name = module.key_pair.this_key_pair_key_name

  tags = {
    Name = "HelloWorld"
  }
}

output "ip" {
  value = aws_eip.ip.public_ip
}

output "pub_pem" {
  value = tls_private_key.this.public_key_pem
}
