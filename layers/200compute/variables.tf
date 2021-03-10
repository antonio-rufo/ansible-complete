###############################################################################
# Variables - Environment
###############################################################################
variable "aws_account_id" {
  description = "AWS Account ID."
}

variable "region" {
  description = "Default Region."
  default     = "ap-southeast-2"
}

variable "environment" {
  description = "Name of the environment for the deployment, e.g. Integration, PreProduction, Production, QA, Staging, Test."
  default     = "Development"
}

###############################################################################
# Variables - Security Group
###############################################################################
variable "security_group_bastion_name" {
  description = "Name for the Bastion security group."
}

variable "security_group_ansible_target_name" {
  description = "Name for the Ansible security group."
}

variable "security_group_terraform_name" {
  description = "Name for the Terraform security group."
}

variable "security_group_targets_name" {
  description = "Name for the targets security group."
}

###############################################################################
# Variables - Instances
###############################################################################
variable "key_pair_bastion" {
  description = "Bastion Host Key Pair."
}

variable "key_pair" {
  description = "Instances Key Pair."
}

variable "instance_type_bastion" {
  description = "Bastion Host Instance Type."
}

variable "instance_type_ansible_target" {
  description = "Ansible Target Instance Type."
}

variable "instance_name_bastion" {
  description = "Bastion Host Instance Name."
}

variable "instance_name_ansible_target" {
  description = "Ansible Server Instance Name."
}

variable "instance_name_terraform" {
  description = "Terraform Server Instance Name."
}

variable "instance_name_targets" {
  description = "Targets Server Instance Name."
}
