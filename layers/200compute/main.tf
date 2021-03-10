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

# data "aws_ami" "ami" {
#   most_recent = true
#
#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }
#
#   name_regex = "^ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-.*"
#   owners     = ["099720109477"]
# }
#
# data "aws_ami" "centos" {
#   owners      = ["679593333241"]
#   most_recent = true
#
#   filter {
#     name   = "name"
#     values = ["CentOS Linux 7 x86_64 HVM EBS *"]
#   }
#
#   filter {
#     name   = "architecture"
#     values = ["x86_64"]
#   }
#
#   filter {
#     name   = "root-device-type"
#     values = ["ebs"]
#   }
# }

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
# # Bastion
# resource "aws_security_group" "security_group_bastion" {
#   name        = var.security_group_bastion_name
#   description = "SSH security group for bastion host"
#   vpc_id      = local.vpc_id
#
#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#
#   egress {
#     from_port   = 1
#     to_port     = 65535
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#
#   tags = {
#     Name        = var.security_group_bastion_name
#     Environment = var.environment
#   }
# }

# Ansible
resource "aws_security_group" "security_group_ansible_target" {
  name = var.security_group_ansible_target_name
  # description = "Bastion host access to Ansible Server"
  description = "Access to Ansible Target Server"
  vpc_id      = local.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    # security_groups = [aws_security_group.security_group_bastion.id]
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

# # Targets
# resource "aws_security_group" "security_group_targets" {
#   name        = var.security_group_targets_name
#   description = "Ansible access to Target Servers"
#   vpc_id      = local.vpc_id
#
#   ingress {
#     from_port       = 22
#     to_port         = 22
#     protocol        = "tcp"
#     security_groups = [aws_security_group.security_group_ansible.id]
#   }
#
#   ingress {
#     from_port       = 8
#     to_port         = 8
#     protocol        = "icmp"
#     security_groups = [aws_security_group.security_group_ansible.id]
#   }
#
#   egress {
#     from_port   = 1
#     to_port     = 65535
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#
#   tags = {
#     Name        = var.security_group_targets_name
#     Environment = var.environment
#   }
# }

# # Terraform
# resource "aws_security_group" "security_group_terraform" {
#   name        = var.security_group_terraform_name
#   description = "Bastion Host access to Terraform Server"
#   vpc_id      = local.vpc_id
#
#   ingress {
#     from_port       = 22
#     to_port         = 22
#     protocol        = "tcp"
#     security_groups = [aws_security_group.security_group_bastion.id]
#   }
#
#   egress {
#     from_port   = 1
#     to_port     = 65535
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#
#   tags = {
#     Name        = var.security_group_terraform_name
#     Environment = var.environment
#   }
# }

###############################################################################
# ENI
###############################################################################
# resource "aws_network_interface" "eni_bastion" {
#   subnet_id       = local.public_subnets[0]
#   security_groups = [local.bastion_sg]
#
#   tags = {
#     Network = "ENI Bastion Host"
#   }
# }

resource "aws_network_interface" "eni_ansible_target" {
  subnet_id       = local.public_subnets[0]
  security_groups = [aws_security_group.security_group_ansible_target.id]

  tags = {
    Network = "ENI Ansible Target"
  }
}


# ###############################################################################
# # EC2 Instance - Bastion
# ###############################################################################
# resource "aws_instance" "instance_bastion" {
#   ami           = data.aws_ami.amazon-linux-2.image_id
#   instance_type = var.instance_type_bastion
#   key_name      = var.key_pair_bastion
#
#   network_interface {
#     network_interface_id = aws_network_interface.eni_bastion.id
#     device_index         = 0
#   }
#
#   tags = {
#     Name = var.instance_name_bastion
#   }
#
#   provisioner "file" {
#     source      = "~/Desktop/Qantas/Testing/SSH/antonio-qantas.pem"
#     destination = "/home/ec2-user/antonio-qantas.pem"
#
#     connection {
#       type        = "ssh"
#       user        = "ec2-user"
#       private_key = file("~/Desktop/Qantas/Testing/SSH/antonio-qantas.pem")
#       host        = self.public_dns
#     }
#   }
# }

###############################################################################
# EC2 Instance - Ansible
###############################################################################
resource "aws_instance" "instance_ansible_target" {
  ami           = data.aws_ami.amazon-linux-2.image_id
  instance_type = var.instance_type_ansible_target
  key_name      = var.key_pair
  # vpc_security_group_ids = [local.ansible_sg]
  # subnet_id              = local.private_subnets[0]
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

# ###############################################################################
# # EC2 Instance - targets
# ###############################################################################
# resource "aws_instance" "instance_targets" {
#   # count                  = 2
#   ami                    = data.aws_ami.amazon-linux-2.image_id
#   instance_type          = var.instance_type_bastion
#   key_name               = var.key_pair
#   vpc_security_group_ids = [aws_security_group.security_group_targets.id]
#   subnet_id              = local.private_subnets[0]
#
#   tags = {
#     # Name = "${var.instance_name_targets} ${count.index + 1}"
#     Name = var.instance_name_targets
#   }
# }

# ###############################################################################
# # EC2 Instance - Terraform
# ###############################################################################
# resource "aws_instance" "instance_terraform" {
#   ami             = data.aws_ami.centos.image_id
#   instance_type   = var.instance_type_bastion
#   key_name        = var.key_pair
#   security_groups = [aws_security_group.security_group_terraform.id]
#   subnet_id       = local.private_subnets[0]
#
#   user_data_base64 = base64encode(local.user_data)
#
#   tags = {
#     Name = var.instance_name_terraform
#   }
# }
