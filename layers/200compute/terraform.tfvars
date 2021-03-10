###############################################################################
# Environment
###############################################################################
aws_account_id = "130541009828"
region         = "ap-southeast-2"
environment    = "Development"

###############################################################################
# Security Groups
###############################################################################
security_group_bastion_name        = "bastion-security-group"
security_group_ansible_target_name = "ansible-security-group"
security_group_terraform_name      = "terraform-security-group"
security_group_targets_name        = "targets-security-group"

###############################################################################
key_pair_bastion             = "antonio-qantas"
key_pair                     = "antonio-qantas"
instance_type_bastion        = "t2.micro"
instance_type_ansible_target = "t2.micro"
instance_name_bastion        = "Bastion Server"
instance_name_ansible_target = "Ansible Target Server"
instance_name_terraform      = "Terraform Server"
instance_name_targets        = "Target Server"
