###############################################################################
# Compute Output
###############################################################################
output "ansible_target_ip" {
  description = "The Public IP of the Ansible Target server."
  value       = aws_instance.instance_ansible_target.public_ip
}
