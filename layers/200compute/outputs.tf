###############################################################################
# Compute Output
###############################################################################
# output "bastion_ip" {
#   description = "The Public IP of the Bastion Host"
#   value       = aws_instance.instance_bastion.public_ip
# }

output "ansible_ip" {
  description = "The Public IP of the Ansible server"
  value       = aws_instance.instance_ansible.public_ip
}

# output "target1_ip" {
#   description = "The Private IP of the Target Server 1"
#   value       = aws_instance.instance_targets[0].private_ip
# }
#
# output "target2_ip" {
#   description = "The Private IP of the Target Server 2"
#   value       = aws_instance.instance_targets[1].private_ip
# }

output "target_ip" {
  description = "The Private IP of the Target Server"
  value       = aws_instance.instance_targets.private_ip
}
