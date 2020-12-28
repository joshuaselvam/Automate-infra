# SSH user
output "ssh_user" {
  value = "ubuntu"
}

output "manager-instance_id" {
  description = "List of IDs of manager instances"
  value       = aws_instance.swarm_manager.*.id
}

output "worker-instance_id" {
  description = "List of IDs of worker instances"
  value       = aws_instance.swarm_worker.*.id
}

output "manager_public_ip" {
  description = "List of public IP addresses assigned to the instances, if applicable"
  value       = aws_eip.manager.*.public_ip
}

output "worker_public_ip" {
  description = "List of public IP addresses assigned to the instances, if applicable"
  value       = aws_eip.worker.*.public_ip
}
