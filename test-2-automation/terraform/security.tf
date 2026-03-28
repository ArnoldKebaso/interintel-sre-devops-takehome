# SSH Key Pair
resource "aws_key_pair" "deployment" {
  key_name   = "assessment-key"
  public_key = tls_private_key.deployment.public_key_openssh

  tags = {
    Name = "deployment-key"
  }
}

# Generate SSH key locally (for demo; in production use pre-generated keys)
resource "tls_private_key" "deployment" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save private key to file (Windows-friendly)
resource "local_file" "private_key" {
  filename        = "${path.module}/assessment-key.pem"
  content         = tls_private_key.deployment.private_key_pem
  file_permission = "0600"

  provisioner "local-exec" {
    command = "echo Done"
  }
}

# Security Group for VM1 (Gateway - Public)
resource "aws_security_group" "vm1" {
  name_prefix = "vm1-sg-"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "vm1-security-group"
  }

  # SSH from your IP only
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.your_ip]
    description = "SSH from your IP"
  }

  # HTTP from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP from anywhere"
  }

  # HTTPS from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS from anywhere"
  }

  # Outbound: allow all
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }
}

# Security Group for VM2 (App Server - Private)
resource "aws_security_group" "vm2" {
  name_prefix = "vm2-sg-"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "vm2-security-group"
  }

  # SSH from VM1 security group only
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.vm1.id]
    description     = "SSH from VM1"
  }

  # All traffic from VM1 (internal communication)
  ingress {
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.vm1.id]
    description     = "All TCP from VM1"
  }

  # Outbound: allow all
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }
}
