output "ssh_user" {
  value = "${module.terraform-ansible-docker.ssh_user}"
}

output "manager-instance_id" {
  description = "List of IDs of manager instances"
  value       = "${module.terraform-ansible-docker.manager-instance_id}"
}

output "worker-instance_id" {
  description = "List of IDs of worker instances"
  value       = "${module.terraform-ansible-docker.worker-instance_id}"
}

output "manager_public_ip" {
  description = "List of public IP addresses assigned to the instances, if applicable"
  value       = "${module.terraform-ansible-docker.manager_public_ip}"
}

output "worker_public_ip" {
  description = "List of public IP addresses assigned to the instances, if applicable"
  value       = "${module.terraform-ansible-docker.worker_public_ip}"
}