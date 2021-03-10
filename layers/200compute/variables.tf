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
variable "security_group_ansible_target_name" {
  description = "Name for the Ansible Target security group."
}

###############################################################################
# Variables - Instances
###############################################################################
variable "key_pair" {
  description = "Instances Key Pair."
}

variable "instance_type_ansible_target" {
  description = "Ansible Target Instance Type."
}

variable "instance_name_ansible_target" {
  description = "Ansible Target Server Instance Name."
}
