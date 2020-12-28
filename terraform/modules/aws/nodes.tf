# Key Pair for SSH
 resource "aws_key_pair" "local" {
  key_name   = "${var.ssh_pubkey_name}-${var.environment}"
  public_key = file(var.ssh_pubkey_path)
} 

## MANAGER NODES
# Spread placement group for Swarm manager nodes
resource "aws_placement_group" "swarm_manager_nodes" {
  name     = "terraform-${var.environment}-swarm-manager-nodes"
  strategy = "spread"
}

resource "aws_instance" "swarm_manager" {
  count                     = var.swarm_manager_nodes
  ami                       = "ami-0245841fc4b40e22f" 
  instance_type             = var.aws_nodes_instance_type
  user_data                 = local.nodes_user_data
  key_name                  = aws_key_pair.local.id
  ebs_optimized             = "true"
  disable_api_termination   = "true"
  iam_instance_profile      = aws_iam_instance_profile.instance-profile-docker-registry-s3.name
  subnet_id                 = element(
                              compact(aws_subnet.swarm_nodes.*.id),
                              count.index,
                              )
  placement_group           = aws_placement_group.swarm_manager_nodes.id
  vpc_security_group_ids    = [aws_security_group.swarm_node.id, aws_security_group.swarm_manager_node.id]
  dynamic "root_block_device" {
    for_each = var.root_block_device
    content {
      delete_on_termination = lookup(root_block_device.value, "delete_on_termination", null)
      encrypted             = lookup(root_block_device.value, "encrypted", null)
      iops                  = lookup(root_block_device.value, "iops", null)
      kms_key_id            = lookup(root_block_device.value, "kms_key_id", null)
      volume_size           = lookup(root_block_device.value, "volume_size", null)
      volume_type           = lookup(root_block_device.value, "volume_type", null)
    }
  }

  dynamic "ebs_block_device" {
    for_each = var.ebs_block_device
    content {
      delete_on_termination = lookup(ebs_block_device.value, "delete_on_termination", null)
      device_name           = ebs_block_device.value.device_name
      encrypted             = lookup(ebs_block_device.value, "encrypted", null)
      iops                  = lookup(ebs_block_device.value, "iops", null)
      kms_key_id            = lookup(ebs_block_device.value, "kms_key_id", null)
      snapshot_id           = lookup(ebs_block_device.value, "snapshot_id", null)
      volume_size           = lookup(ebs_block_device.value, "volume_size", null)
      volume_type           = lookup(ebs_block_device.value, "volume_type", null)
    }
  }
  tags = merge(
    {
      "Name" = var.swarm_manager_nodes > 1 || var.use_num_suffix ? format("%s-%d", var.manger_name, count.index + 1) : var.manger_name
    },
    var.tags,
  )

  volume_tags = merge(
    {
      "Name" = var.swarm_manager_nodes > 1 || var.use_num_suffix ? format("%s-%d", var.manger_name, count.index + 1) : var.manger_name
    },
    var.volume_tags,
  )
}
#Elastic IP
resource "aws_eip" "manager" {
  count = var.swarm_manager_nodes
  network_interface = element(aws_instance.swarm_manager.*.primary_network_interface_id, count.index)
  vpc      = true
}


## WORKER NODES
# Spread placement group for Swarm worker nodes
resource "aws_placement_group" "swarm_worker_nodes" {
  name     = "terraform-${var.environment}-swarm-worker-nodes"
  strategy = "spread"
}

resource "aws_instance" "swarm_worker" {
  count                     = var.swarm_worker_nodes
  ami                       = data.aws_ami.latest-ubuntu.id
  instance_type             = var.aws_nodes_instance_type
  user_data                 = local.nodes_user_data
  key_name                  = aws_key_pair.local.id
  iam_instance_profile      = aws_iam_instance_profile.instance-profile-docker-registry-s3.name
  subnet_id                 = element(
                              compact(aws_subnet.swarm_nodes.*.id),
                              count.index,
                              )
  placement_group           = aws_placement_group.swarm_worker_nodes.id
  vpc_security_group_ids    = [aws_security_group.swarm_node.id]
  dynamic "root_block_device" {
    for_each = var.root_block_device
    content {
      delete_on_termination = lookup(root_block_device.value, "delete_on_termination", null)
      encrypted             = lookup(root_block_device.value, "encrypted", null)
      iops                  = lookup(root_block_device.value, "iops", null)
      kms_key_id            = lookup(root_block_device.value, "kms_key_id", null)
      volume_size           = lookup(root_block_device.value, "volume_size", null)
      volume_type           = lookup(root_block_device.value, "volume_type", null)
    }
  }

  dynamic "ebs_block_device" {
    for_each = var.ebs_block_device
    content {
      delete_on_termination = lookup(ebs_block_device.value, "delete_on_termination", null)
      device_name           = ebs_block_device.value.device_name
      encrypted             = lookup(ebs_block_device.value, "encrypted", null)
      iops                  = lookup(ebs_block_device.value, "iops", null)
      kms_key_id            = lookup(ebs_block_device.value, "kms_key_id", null)
      snapshot_id           = lookup(ebs_block_device.value, "snapshot_id", null)
      volume_size           = lookup(ebs_block_device.value, "volume_size", null)
      volume_type           = lookup(ebs_block_device.value, "volume_type", null)
    }
  }
  tags = merge(
    {
      "Name" = var.swarm_worker_nodes > 1 || var.use_num_suffix ? format("%s-%d", var.worker_name, count.index + 1) : var.worker_name
    },
    var.tags,
  )

  volume_tags = merge(
    {
      "Name" = var.swarm_worker_nodes > 1 || var.use_num_suffix ? format("%s-%d", var.worker_name, count.index + 1) : var.worker_name
    },
    var.volume_tags,
  )
}
#Elastic IP
resource "aws_eip" "worker" {
  count = var.swarm_worker_nodes
  network_interface = element(aws_instance.swarm_worker.*.primary_network_interface_id, count.index)
  vpc      = true
}


# Bootstrap script for instances
locals {
  nodes_user_data = <<EOF
#!/bin/bash
set -e
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y python-pip
	EOF
}
