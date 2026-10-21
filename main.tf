terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-south-1"
}

variable "ser1" {
  description = "Name of first server"
  type = string
  default = "serverA"
}

variable "ser2" {
  description = "Name of second server"
  type = string
  default = "serverB"
}

variable "ser3" {
  description = "Name of third server"
  type = string
  default = "serverC"
}

variable "instance_type" {
  description = "Instance type of ec2"
  type = string
  default = "t3.micro"
}

variable "key_pair" {
  description = "Key pair for ec2"
  type = string
  default = "key"
}

resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

data "aws_security_group" "selected" {
  name = "allow_tls"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "example" {
  for_each = toset([var.ser1, var.ser2, var.ser3])
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name = var.key_pair
  vpc_security_group_ids = [ data.aws_security_group.selected.id ]

  tags = {
    Name = each.key
  }
}



