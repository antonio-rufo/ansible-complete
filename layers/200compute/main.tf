###############################################################################
# Terraform main config
###############################################################################
terraform {
  required_version = ">= 0.14"
  required_providers {
    aws = "~> 3.6.0"
  }
  backend "s3" {
    bucket  = "130541009828-build-state-bucket-ansible-complete"
    key     = "terraform.development.200compute.tfstate"
    region  = "ap-southeast-2"
    encrypt = "true"
  }
}

###############################################################################
# Terraform Remote State
###############################################################################
# 000base
data "terraform_remote_state" "_000base" {
  backend = "s3"

  config = {
    bucket  = "130541009828-build-state-bucket-ansible-complete"
    key     = "terraform.development.000base.tfstate"
    region  = "ap-southeast-2"
    encrypt = "true"
  }
}

###############################################################################
# Providers
###############################################################################
provider "aws" {
  region              = var.region
  allowed_account_ids = [var.aws_account_id]
}

locals {
  vpc_id          = data.terraform_remote_state._000base.outputs.vpc_id
  private_subnets = data.terraform_remote_state._000base.outputs.private_subnets
  public_subnets  = data.terraform_remote_state._000base.outputs.public_subnets

  tags = {
    Environment = var.environment
  }

  user_data_ansible_target = <<EOF
#!/bin/bash
amazon-linux-extras install epel
yum update -y
yum install git ansible -y
EOF

}

###############################################################################
# Data Sources
###############################################################################
data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

###############################################################################
# Security Groups
###############################################################################
# Ansible Target SG
resource "aws_security_group" "security_group_ansible_target" {
  name        = var.security_group_ansible_target_name
  description = "Access to Ansible Target Server"
  vpc_id      = local.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 1
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = var.security_group_ansible_target_name
    Environment = var.environment
  }
}

###############################################################################
# ENI
###############################################################################
resource "aws_network_interface" "eni_ansible_target" {
  subnet_id       = local.public_subnets[0]
  security_groups = [aws_security_group.security_group_ansible_target.id]

  tags = {
    Network = "ENI Ansible Target"
  }
}

###############################################################################
# EC2 Instance - Ansible
###############################################################################
resource "aws_instance" "instance_ansible_target" {
  ami              = data.aws_ami.amazon-linux-2.image_id
  instance_type    = var.instance_type_ansible_target
  key_name         = var.key_pair
  user_data_base64 = base64encode(local.user_data_ansible_target)

  network_interface {
    network_interface_id = aws_network_interface.eni_ansible_target.id
    device_index         = 0
  }

  provisioner "file" {
    source      = "~/Desktop/Qantas/Testing/SSH/antonio-qantas.pem"
    destination = "/home/ec2-user/antonio-qantas.pem"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("~/Desktop/Qantas/Testing/SSH/antonio-qantas.pem")
      host        = self.public_dns
    }
  }

  tags = {
    Name = var.instance_name_ansible_target
  }
}
