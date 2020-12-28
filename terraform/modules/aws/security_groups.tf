# A security group for Swarm nodes
resource "aws_security_group" "swarm_node" {
  name   = "terraform-${var.environment}-swarm-node"
  vpc_id = aws_vpc.swarm.id

  # Docker Swarm ports from this security group only
  ingress {
    description = "Docker container network discovery"
    from_port   = 7946
    to_port     = 7946
    protocol    = "tcp"
    self        = true
  }
  ingress {
    description = "Docker container network discovery"
    from_port   = 7946
    to_port     = 7946
    protocol    = "udp"
    self        = true
  }
  ingress {
    description = "Docker overlay network"
    from_port   = 4789
    to_port     = 4789
    protocol    = "udp"
    self        = true
  }
  # MongoDB Replication ports
  ingress {
    description = "MongoDB Replication ports"
    from_port   = 27017
    to_port     = 27019
    protocol    = "tcp"
    self        = true
    
  }

  # SSH for Ansible
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_cidr_blocks
  }
  # Docker Swarm Registry  only
  ingress {
    description     = "Docker Swarm Registry Connections"
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    self            = true

  }

  # Outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# A security group for Swarm manager nodes only
resource "aws_security_group" "swarm_manager_node" {
  name   = "terraform-${var.environment}-swarm-manager-node"
  vpc_id = aws_vpc.swarm.id

  # Docker Swarm manager only
  ingress {
    description     = "Docker Swarm management between managers"
    from_port       = 2377
    to_port         = 2377
    protocol        = "tcp"
    security_groups = [aws_security_group.swarm_node.id]
  }
  # HTTP access from outside
  ingress {
    description     = "Prod Http Traefik instance port for public access"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks = var.web_cidr_blocks
  }

  # HTTPS access from Outside
  ingress {
    description     = "Prod Https Traefik instance port for public access"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks = var.web_cidr_blocks
  }
  # Postgres Prod/dev Instance
  ingress {
    description     = "Postgres dev and prod instance"
    from_port       = 5432
    to_port         = 5433
    protocol        = "tcp"
    cidr_blocks = var.web_cidr_blocks
  }
  # Mongo Prod/dev Instance
  ingress {
    description     = "Mongo Dev Instance Port"
    from_port       = 10080
    to_port         = 10080
    protocol        = "tcp"
    cidr_blocks = var.web_cidr_blocks
  }

}