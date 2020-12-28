# Required variables
variable "environment" {
  description = "The environment name. Used to name resources"
}

variable "swarm_vpc_cidr" {
  description = "Your Swarm VPC CIDR"
}

variable "swarm_vpc_subnets" {
  description = "Your Swarm VPC subnets. Ideally one per AZ"
}

# Optional variables
variable "ssh_pubkey_name" {
  description = "Desired name of AWS SSH key pair"
  default     = "terraform"
}

variable "ssh_pubkey_path" {
  description = "Local path to your SSH public key"
  default     = "~/.ssh/id_rsa.pub"
}

variable "ssh_cidr_blocks" {
  description = "Allowed CIDR blocks to SSH nodes from"
  default     = ["0.0.0.0/0"] # you should definitely secure this
}

variable "web_cidr_blocks" {
  description = "Allowed CIDR blocks for WEB Traffic"
  default     = ["0.0.0.0/0"] # you should definitely secure this
}
variable "aws_nodes_instance_type" {
  description = "The AWS instance type of your Swarm nodes"
  default     = "t2.micro" # free tier
}

variable "swarm_manager_nodes" {
  description = "Number of Docker Swarm manager nodes to create"
  default     = 3
}

variable "swarm_worker_nodes" {
  description = "Number of Docker Swarm worker nodes to create"
  default     = 0
}

variable "manger_name" {
  description = "Name to be used on all resources as prefix"
  type        = string
  default     = "Docker-Swarm-Manager"
}

variable "worker_name" {
  description = "Name to be used on all resources as prefix"
  type        = string
  default     = "Docker-Swarm-Worker"
}

variable "infra_s3bucket" {
  description = "Name to be used on all resources as prefix"
  type        = list
  default     = []
}

variable "nonprod_s3bucket" {
  description = "Name to be used on all resources as prefix"
  type        = list
  default     = []
}

variable "prod_s3bucket" {
  description = "Name to be used on all resources as prefix"
  type        = list
  default     = []
}


variable "iam_username" {
  type = list
  default = []
}

variable "root_block_device" {
  description = "Customize details about the root block device of the instance. See Block Devices below for details"
  type        = list(map(string))
  default     = [{volume_size="30",encrypted="true"}]
}

variable "ebs_block_device" {
  description = "Additional EBS block devices to attach to the instance"
  type        = list(map(string))
  default     = []
}

variable "use_num_suffix" {
  description = "Always append numerical suffix to instance name, even if instance_count is 1"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {Orchestrator="Swarm"}
}
variable "volume_tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {Orchestrator="Swarm"}
}

